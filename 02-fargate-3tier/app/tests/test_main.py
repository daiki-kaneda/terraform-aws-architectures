from fastapi.testclient import TestClient

from app.main import SERVICE_NAME, app

client = TestClient(app)


def test_hello() -> None:
    response = client.get("/")

    assert response.status_code == 200
    assert response.json() == {"message": "Hello, world!!", "service": SERVICE_NAME}


def test_health() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
