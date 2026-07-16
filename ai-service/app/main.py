from contextlib import asynccontextmanager
from typing import Annotated, AsyncIterator

import asyncpg
from fastapi import Depends, FastAPI, Header, HTTPException, Request, status

from app.models import RecommendationRequest, RecommendationResponse
from app.recommender import ExplainableRecommender
from app.repository import DiscoveryCatalogRepository
from app.settings import settings


@asynccontextmanager
async def lifespan(application: FastAPI) -> AsyncIterator[None]:
    pool = await asyncpg.create_pool(
        settings.database_url,
        min_size=1,
        max_size=5,
        command_timeout=1.0,
    )
    application.state.repository = DiscoveryCatalogRepository(pool, settings.catalog_cache_seconds)
    application.state.recommender = ExplainableRecommender(settings.model_version)
    yield
    await pool.close()


app = FastAPI(
    title="Rota AI Recommendation Service",
    version="1.0.0",
    description="Explainable content-based neighborhood, place and Timeline recommendations.",
    lifespan=lifespan,
)


def get_repository(request: Request) -> DiscoveryCatalogRepository:
    return request.app.state.repository


def get_recommender(request: Request) -> ExplainableRecommender:
    return request.app.state.recommender


@app.get("/health/live", tags=["Health"])
async def live() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/health/ready", tags=["Health"])
async def ready(
    repository: Annotated[DiscoveryCatalogRepository, Depends(get_repository)],
) -> dict[str, str]:
    if not await repository.is_ready():
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Discovery catalog is not ready")
    return {"status": "ready"}


@app.post(
    "/api/v1/recommendations/generate",
    response_model=RecommendationResponse,
    tags=["Recommendations"],
)
async def generate_recommendation(
    payload: RecommendationRequest,
    repository: Annotated[DiscoveryCatalogRepository, Depends(get_repository)],
    recommender: Annotated[ExplainableRecommender, Depends(get_recommender)],
    correlation_id: Annotated[str | None, Header(alias="X-Correlation-ID")] = None,
) -> RecommendationResponse:
    if correlation_id != payload.correlation_id:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Correlation ID mismatch")
    catalog = await repository.get_places()
    try:
        return recommender.recommend(payload, catalog)
    except ValueError as exception:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=str(exception)) from exception
