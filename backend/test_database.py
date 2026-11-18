import io
import os
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch

from alembic import command
from alembic.config import Config
from sqlalchemy import create_engine, inspect

from database import Base, get_engine


class DatabaseTests(unittest.TestCase):
    def tearDown(self):
        get_engine.cache_clear()

    @patch.dict(os.environ, {"DATABASE_URL": "postgresql://user:pass@localhost/test"})
    @patch("database.create_engine")
    def test_engine_uses_psycopg_pooling_and_timeouts(self, create):
        get_engine.cache_clear()
        self.assertIs(get_engine(), get_engine())
        create.assert_called_once()
        args, kwargs = create.call_args
        self.assertEqual(args[0].drivername, "postgresql+psycopg")
        self.assertEqual(args[0].password, "pass")
        self.assertTrue(kwargs["pool_pre_ping"])
        self.assertEqual(kwargs["pool_timeout"], 3)
        self.assertEqual(
            kwargs["connect_args"],
            {"connect_timeout": 3, "options": "-c statement_timeout=3000"},
        )

    def test_alembic_online_environment(self):
        config = Config(str(Path(__file__).with_name("alembic.ini")))
        with TemporaryDirectory() as directory:
            engine = create_engine(f"sqlite:///{Path(directory) / 'test.db'}")
            try:
                with patch("database.get_engine", return_value=engine):
                    command.upgrade(config, "head")
                    self.assertEqual(inspect(engine).get_table_names(), ["alembic_version"])
                    command.check(config)
                    command.downgrade(config, "base")
                self.assertEqual(list(Base.metadata.tables), [])
            finally:
                engine.dispose()

    @patch.dict(os.environ, {"DATABASE_URL": "postgresql://localhost/unipath_test"})
    def test_alembic_offline_requires_no_database_connection(self):
        get_engine.cache_clear()
        output = io.StringIO()
        config = Config(
            str(Path(__file__).with_name("alembic.ini")), output_buffer=output
        )
        with patch("psycopg.connect") as connect:
            command.upgrade(config, "head", sql=True)
        connect.assert_not_called()
        self.assertIn("COMMIT", output.getvalue())
        get_engine().dispose()


if __name__ == "__main__":
    unittest.main()
