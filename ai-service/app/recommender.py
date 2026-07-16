import math
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime, time, timedelta
from uuid import UUID

from app.models import (
    PlaceRecommendation,
    RecommendationRequest,
    RecommendationResponse,
    RegionRecommendation,
    TimelineItem,
)
from app.repository import PlaceCandidate


BUDGET_FRIENDLY_TAG = "bütçe dostu"
VEGAN_TAG = "vegan seçenekli"


@dataclass(frozen=True, slots=True)
class ScoredPlace:
    place: PlaceCandidate
    score: float
    reasons: tuple[str, ...]


class ExplainableRecommender:
    def __init__(self, model_version: str) -> None:
        self._model_version = model_version

    def recommend(
        self,
        request: RecommendationRequest,
        catalog: tuple[PlaceCandidate, ...],
    ) -> RecommendationResponse:
        if not catalog:
            raise ValueError("Discovery kataloğunda önerilebilir mekan bulunamadı")

        scored = [self._score_place(place, request) for place in catalog]
        region_id, region_places, region_score = self._select_region(scored, request)
        ordered = self._route_order(region_places[:10], request)
        timeline_places, timeline = self._build_timeline(ordered, request)
        selected_ids = {item.place_id for item in timeline}
        recommendations = [
            PlaceRecommendation(
                place_id=item.place.id,
                name=item.place.name,
                score=item.score,
                explanation=self._place_explanation(item),
            )
            for item in region_places
            if item.place.id in selected_ids
        ]
        recommendation_by_id = {item.place_id: item for item in recommendations}
        recommendations = [recommendation_by_id[item.place.id] for item in timeline_places]
        first = region_places[0].place
        return RecommendationResponse(
            model_version=self._model_version,
            region=RegionRecommendation(
                neighborhood_id=region_id,
                name=first.neighborhood_name,
                score=region_score,
                explanation=self._region_explanation(region_places, request),
            ),
            places=recommendations,
            timeline=timeline,
            overall_explanation=(
                "Kategori, etiket, beslenme, bütçe ve başlangıç mesafesi sinyalleri ağırlıklı "
                "olarak birlikte değerlendirildi. Timeline, seçilen mahallede süre sınırına "
                "uyacak ve duraklar arası mesafeyi azaltacak şekilde sıralandı."
            ),
        )

    def _score_place(self, place: PlaceCandidate, request: RecommendationRequest) -> ScoredPlace:
        profile = request.taste_profile
        preferred_categories = set(profile.preferred_category_ids)
        preferred_tags = set(profile.preferred_tag_ids)
        category_match = 1.0 if place.category_id in preferred_categories else 0.0
        tag_match = len(set(place.tag_ids) & preferred_tags) / max(1, len(preferred_tags))
        normalized_tags = {name.casefold() for name in place.tag_names}
        wants_vegan = any("vegan" in item.casefold() for item in profile.dietary_preferences)
        diet_match = 1.0 if wants_vegan and VEGAN_TAG in normalized_tags else (0.5 if not wants_vegan else 0.0)
        wants_budget = profile.budget_level.casefold() in {"low", "budget", "economy", "düşük", "ekonomik"}
        budget_match = 1.0 if wants_budget and BUDGET_FRIENDLY_TAG in normalized_tags else (0.5 if not wants_budget else 0.0)
        distance_match = self._distance_score(place, request)

        has_preferences = bool(preferred_categories or preferred_tags or wants_vegan or wants_budget)
        preference_score = (
            0.35 * category_match
            + 0.30 * tag_match
            + 0.15 * diet_match
            + 0.10 * budget_match
            + 0.10 * distance_match
        )
        score = preference_score if has_preferences else 0.55 + 0.20 * distance_match
        reasons: list[str] = []
        if category_match:
            reasons.append(f"{place.category_name} kategori tercihi")
        matched_tag_names = [name for tag_id, name in zip(place.tag_ids, place.tag_names) if tag_id in preferred_tags]
        if matched_tag_names:
            reasons.append(f"{', '.join(matched_tag_names)} etiket eşleşmesi")
        if wants_vegan and diet_match:
            reasons.append("vegan seçenek")
        if wants_budget and budget_match:
            reasons.append("bütçe dostu seçenek")
        if request.start_location and distance_match >= 0.5:
            reasons.append("başlangıç konumuna yakınlık")
        if not reasons:
            reasons.append("bölgedeki dengeli çeşitlilik")
        return ScoredPlace(place, self._round_score(score), tuple(reasons))

    def _select_region(
        self,
        scored: list[ScoredPlace],
        request: RecommendationRequest,
    ) -> tuple[UUID, list[ScoredPlace], float]:
        groups: dict[UUID, list[ScoredPlace]] = defaultdict(list)
        for item in scored:
            groups[item.place.neighborhood_id].append(item)
        ranked: list[tuple[float, UUID, list[ScoredPlace]]] = []
        for region_id, items in groups.items():
            items.sort(key=lambda item: (-item.score, item.place.name))
            top = items[:6]
            average = sum(item.score for item in top) / len(top)
            diversity = len({item.place.category_id for item in top}) / max(1, min(4, len(top)))
            proximity = max(self._distance_score(item.place, request) for item in top)
            score = self._round_score(0.75 * average + 0.15 * min(1.0, diversity) + 0.10 * proximity)
            ranked.append((score, region_id, items))
        score, region_id, items = max(ranked, key=lambda item: (item[0], str(item[1])))
        return region_id, items, score

    def _route_order(
        self,
        candidates: list[ScoredPlace],
        request: RecommendationRequest,
    ) -> list[ScoredPlace]:
        remaining = candidates.copy()
        ordered: list[ScoredPlace] = []
        if request.start_location:
            longitude, latitude = request.start_location.longitude, request.start_location.latitude
        else:
            first = remaining.pop(0)
            ordered.append(first)
            longitude, latitude = first.place.longitude, first.place.latitude
        while remaining:
            next_item = min(
                remaining,
                key=lambda item: self._haversine_km(
                    longitude,
                    latitude,
                    item.place.longitude,
                    item.place.latitude,
                ) - item.score * 0.15,
            )
            remaining.remove(next_item)
            ordered.append(next_item)
            longitude, latitude = next_item.place.longitude, next_item.place.latitude
        return ordered

    def _build_timeline(
        self,
        ordered: list[ScoredPlace],
        request: RecommendationRequest,
    ) -> tuple[list[ScoredPlace], list[TimelineItem]]:
        pace = request.taste_profile.travel_pace.casefold()
        duration = 90 if pace in {"slow", "leisurely", "yavaş", "rahat"} else 60 if pace in {"fast", "hızlı"} else 75
        travel_minutes = 15
        elapsed = 0
        start = datetime.combine(request.trip_date, time(9, 0))
        selected: list[ScoredPlace] = []
        timeline: list[TimelineItem] = []
        for item in ordered:
            if elapsed + duration > request.available_minutes:
                break
            selected.append(item)
            timeline.append(
                TimelineItem(
                    sequence=len(timeline) + 1,
                    place_id=item.place.id,
                    place_name=item.place.name,
                    start_time=(start + timedelta(minutes=elapsed)).time(),
                    duration_minutes=duration,
                    explanation=f"{self._place_explanation(item)} Sonraki durakla mesafe dengesi gözetildi.",
                )
            )
            elapsed += duration + travel_minutes
        if not timeline:
            item = ordered[0]
            selected.append(item)
            timeline.append(
                TimelineItem(
                    sequence=1,
                    place_id=item.place.id,
                    place_name=item.place.name,
                    start_time=start.time(),
                    duration_minutes=min(duration, request.available_minutes),
                    explanation=self._place_explanation(item),
                )
            )
        return selected, timeline

    def _region_explanation(self, items: list[ScoredPlace], request: RecommendationRequest) -> str:
        categories = sorted({item.place.category_name for item in items[:5]})
        location_text = " ve başlangıç konumuna yakınlığı" if request.start_location else ""
        return f"Öne çıkan {', '.join(categories)} seçenekleri{location_text} nedeniyle en güçlü bölge eşleşmesi."

    @staticmethod
    def _place_explanation(item: ScoredPlace) -> str:
        return f"Skoru belirleyen sinyaller: {', '.join(item.reasons)}."

    def _distance_score(self, place: PlaceCandidate, request: RecommendationRequest) -> float:
        if request.start_location is None:
            return 0.5
        distance = self._haversine_km(
            request.start_location.longitude,
            request.start_location.latitude,
            place.longitude,
            place.latitude,
        )
        return math.exp(-distance / 5.0)

    @staticmethod
    def _haversine_km(lon1: float, lat1: float, lon2: float, lat2: float) -> float:
        radius = 6371.0088
        phi1, phi2 = math.radians(lat1), math.radians(lat2)
        delta_phi = math.radians(lat2 - lat1)
        delta_lambda = math.radians(lon2 - lon1)
        value = math.sin(delta_phi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2
        return 2 * radius * math.asin(math.sqrt(value))

    @staticmethod
    def _round_score(value: float) -> float:
        return round(max(0.0, min(1.0, value)), 4)
