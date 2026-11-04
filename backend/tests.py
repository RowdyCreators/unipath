from fastapi.testclient import TestClient
from main import app


client = TestClient(app)


def test_auth():
    response = client.post("/api/auth", data={})
    assert response.status_code == 200
