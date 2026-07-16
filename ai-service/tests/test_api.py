from contextlib import asynccontextmanager
from datetime import date
from uuid import UUID

from fastapi.testclient import TestClient

from app.main import app
from app.recommender import ExplainableRecommender
from app.repository import PlaceCandidate


class FakeRepository:
    async def get_places(self):
        return (
            PlaceCandidate(
                id=UUID("50000000-0000-0000-0000-000000000001"),
                name="Moda Kahve Noktası",
                neighborhood_id=UUID("20000000-0000-0000-0000-000000000001"),
                neighborhood_name="Caferağa",
                category_id=UUID("30000000-0000-0000-0000-000000000001"),
                category_name="Kafe",
                tag_ids=(),
                tag_names=(),
                longitude=29.0257,
                latitude=40.9848,
            ),
        )

    async def is_ready(self):
        return True


@asynccontextmanager
async def fake_lifespan(application):
    application.state.repository = FakeRepository()
    application.state.recommender = ExplainableRecommender("api-test-v1")
    yield


app.router.lifespan_context = fake_lifespan


def payload():
    return {
        "request_id": "80000000-0000-0000-0000-000000000001",
        "correlation_id": "contract-test",
        "user_id": "60000000-0000-0000-0000-000000000001",
        "trip_date": date(2026, 7, 17).isoformat(),
        "available_minutes": 120,
        "start_location": {"longitude": 29.026, "latitude": 40.985},
        "taste_profile": {
            "preferred_category_ids": ["30000000-0000-0000-0000-000000000001"],
            "preferred_tag_ids": [],
            "dietary_preferences": [],
            "budget_level": "Moderate",
            "travel_pace": "Balanced",
        },
    }


def test_generate_matches_dotnet_contract() -> None:
    with TestClient(app) as client:
        response = client.post(
            "/api/v1/recommendations/generate",
            json=payload(),
            headers={
                "X-Correlation-ID": "contract-test",
                "X-Service-Key": "rota-development-fastapi-service-key-change-me-2026",
            },
        )

    assert response.status_code == 200
    body = response.json()
    assert body["model_version"] == "api-test-v1"
    assert body["region"]["neighborhood_id"] == "20000000-0000-0000-0000-000000000001"
    assert body["places"][0]["place_id"] == "50000000-0000-0000-0000-000000000001"
    assert body["timeline"][0]["start_time"] == "09:00:00"


def test_generate_rejects_correlation_mismatch() -> None:
    with TestClient(app) as client:
        response = client.post(
            "/api/v1/recommendations/generate",
            json=payload(),
            headers={
                "X-Correlation-ID": "different",
                "X-Service-Key": "rota-development-fastapi-service-key-change-me-2026",
            },
        )

    assert response.status_code == 422


def test_generate_rejects_missing_service_key() -> None:
    with TestClient(app) as client:
        response = client.post(
            "/api/v1/recommendations/generate",
            json=payload(),
            headers={"X-Correlation-ID": "contract-test"},
        )

    assert response.status_code == 401
