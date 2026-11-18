import os
import unittest
from unittest.mock import patch

from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.exc import OperationalError
from sqlalchemy.pool import StaticPool

from database import get_engine
from main import app


class HealthTests(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)
        get_engine.cache_clear()

    @patch("main.get_engine")
    def test_liveness_does_not_connect_to_database(self, engine):
        response = self.client.get("/api/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"status": "ok"})
        engine.assert_not_called()

    def test_database_health(self):
        engine = create_engine(
            "sqlite://",
            poolclass=StaticPool,
            connect_args={"check_same_thread": False},
        )
        try:
            with patch("main.get_engine", return_value=engine):
                response = self.client.get("/api/health/db")
            self.assertEqual(response.status_code, 200)
            self.assertEqual(response.json(), {"status": "ok", "database": "ok"})
        finally:
            engine.dispose()

    def test_invalid_configuration(self):
        for url in ("", "not-a-url", "sqlite://"):
            with self.subTest(url=url), patch.dict(os.environ, {"DATABASE_URL": url}):
                response = self.client.get("/api/health/db")
                self.assertEqual(response.status_code, 503)
                self.assertEqual(
                    response.json(), {"status": "error", "database": "unavailable"}
                )

    def test_database_errors_are_private_and_connections_released(self):
        for stage in ("connect", "execute", "fetch"):
            with self.subTest(stage=stage), patch("main.get_engine") as engine:
                error = OperationalError(
                    "SELECT 1", {}, Exception("sensitive connection details")
                )
                connection = engine.return_value.connect.return_value.__enter__.return_value
                if stage == "connect":
                    engine.return_value.connect.side_effect = error
                elif stage == "execute":
                    connection.execute.side_effect = error
                else:
                    connection.execute.return_value.scalar_one.side_effect = error
                response = self.client.get("/api/health/db")
                self.assertEqual(response.status_code, 503)
                self.assertEqual(
                    response.json(), {"status": "error", "database": "unavailable"}
                )
                if stage != "connect":
                    engine.return_value.connect.return_value.__exit__.assert_called_once()
                self.assertEqual(self.client.get("/api/health").status_code, 200)


if __name__ == "__main__":
    unittest.main()
