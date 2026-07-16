from datetime import date, time
from typing import Annotated
from uuid import UUID

from pydantic import BaseModel, Field, model_validator


Score = Annotated[float, Field(ge=0, le=1)]


class GeoPoint(BaseModel):
    longitude: float = Field(ge=-180, le=180)
    latitude: float = Field(ge=-90, le=90)


class TasteProfile(BaseModel):
    preferred_category_ids: list[UUID] = Field(default_factory=list, max_length=20)
    preferred_tag_ids: list[UUID] = Field(default_factory=list, max_length=30)
    dietary_preferences: list[str] = Field(default_factory=list, max_length=20)
    budget_level: str = Field(min_length=1, max_length=40)
    travel_pace: str = Field(min_length=1, max_length=40)


class RecommendationRequest(BaseModel):
    request_id: UUID
    correlation_id: str = Field(min_length=1, max_length=200)
    user_id: UUID
    trip_date: date
    available_minutes: int = Field(ge=60, le=720)
    start_location: GeoPoint | None = None
    taste_profile: TasteProfile


class RegionRecommendation(BaseModel):
    neighborhood_id: UUID
    name: str
    score: Score
    explanation: str


class PlaceRecommendation(BaseModel):
    place_id: UUID
    name: str
    score: Score
    explanation: str


class TimelineItem(BaseModel):
    sequence: int = Field(gt=0)
    place_id: UUID
    place_name: str
    start_time: time
    duration_minutes: int = Field(gt=0, le=720)
    explanation: str


class RecommendationResponse(BaseModel):
    model_version: str
    region: RegionRecommendation
    places: list[PlaceRecommendation] = Field(min_length=1, max_length=100)
    timeline: list[TimelineItem] = Field(min_length=1, max_length=50)
    overall_explanation: str

    @model_validator(mode="after")
    def validate_timeline_sequence(self) -> "RecommendationResponse":
        expected = list(range(1, len(self.timeline) + 1))
        if [item.sequence for item in self.timeline] != expected:
            raise ValueError("Timeline sequence must be contiguous and start at one")
        return self
