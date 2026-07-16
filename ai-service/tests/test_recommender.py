from datetime import date
from uuid import UUID

from app.models import GeoPoint, RecommendationRequest, TasteProfile
from app.recommender import ExplainableRecommender
from app.repository import PlaceCandidate


CAFERAGA = UUID("20000000-0000-0000-0000-000000000001")
BESIKTAS = UUID("20000000-0000-0000-0000-000000000002")
CAFE = UUID("30000000-0000-0000-0000-000000000001")
PARK = UUID("30000000-0000-0000-0000-000000000004")
VEGAN = UUID("40000000-0000-0000-0000-000000000005")


def candidate(number: int, neighborhood_id: UUID, neighborhood_name: str, category_id: UUID, tags=()) -> PlaceCandidate:
    return PlaceCandidate(
        id=UUID(f"50000000-0000-0000-0000-{number:012d}"),
        name=f"Mekan {number}",
        neighborhood_id=neighborhood_id,
        neighborhood_name=neighborhood_name,
        category_id=category_id,
        category_name="Kafe" if category_id == CAFE else "Park",
        tag_ids=tuple(tag_id for tag_id, _ in tags),
        tag_names=tuple(name for _, name in tags),
        longitude=29.025 + number / 10000,
        latitude=40.985,
    )


def request(available_minutes: int = 240) -> RecommendationRequest:
    return RecommendationRequest(
        request_id=UUID("80000000-0000-0000-0000-000000000001"),
        correlation_id="test-correlation",
        user_id=UUID("60000000-0000-0000-0000-000000000001"),
        trip_date=date(2026, 7, 17),
        available_minutes=available_minutes,
        start_location=GeoPoint(longitude=29.026, latitude=40.985),
        taste_profile=TasteProfile(
            preferred_category_ids=[CAFE],
            preferred_tag_ids=[VEGAN],
            dietary_preferences=["Vegan"],
            budget_level="Moderate",
            travel_pace="Balanced",
        ),
    )


def test_recommendation_selects_matching_region_and_explains_scores() -> None:
    catalog = (
        candidate(1, CAFERAGA, "Caferağa", CAFE, ((VEGAN, "Vegan Seçenekli"),)),
        candidate(2, CAFERAGA, "Caferağa", CAFE),
        candidate(3, CAFERAGA, "Caferağa", PARK),
        candidate(13, BESIKTAS, "Beşiktaş", PARK),
        candidate(14, BESIKTAS, "Beşiktaş", PARK),
    )

    result = ExplainableRecommender("test-v1").recommend(request(), catalog)

    assert result.region.neighborhood_id == CAFERAGA
    assert result.places[0].place_id == catalog[0].id
    assert "vegan" in result.places[0].explanation.casefold()
    assert result.model_version == "test-v1"


def test_timeline_is_contiguous_and_fits_available_minutes() -> None:
    catalog = tuple(candidate(number, CAFERAGA, "Caferağa", CAFE) for number in range(1, 9))

    result = ExplainableRecommender("test-v1").recommend(request(240), catalog)

    assert [item.sequence for item in result.timeline] == list(range(1, len(result.timeline) + 1))
    assert sum(item.duration_minutes for item in result.timeline) <= 240
    assert len({item.place_id for item in result.timeline}) == len(result.timeline)
    assert all(result.timeline[index].start_time < result.timeline[index + 1].start_time for index in range(len(result.timeline) - 1))


def test_same_input_produces_same_rank_and_timeline() -> None:
    catalog = tuple(candidate(number, CAFERAGA, "Caferağa", CAFE) for number in range(1, 7))
    recommender = ExplainableRecommender("test-v1")

    first = recommender.recommend(request(), catalog)
    second = recommender.recommend(request(), catalog)

    assert [item.place_id for item in first.places] == [item.place_id for item in second.places]
    assert first.timeline == second.timeline
