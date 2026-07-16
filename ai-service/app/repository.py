import asyncio
import time
from dataclasses import dataclass
from uuid import UUID

import asyncpg


@dataclass(frozen=True, slots=True)
class PlaceCandidate:
    id: UUID
    name: str
    neighborhood_id: UUID
    neighborhood_name: str
    category_id: UUID
    category_name: str
    tag_ids: tuple[UUID, ...]
    tag_names: tuple[str, ...]
    longitude: float
    latitude: float


class DiscoveryCatalogRepository:
    _QUERY = """
        SELECT p.id, p.name, p.neighborhood_id, n.name AS neighborhood_name,
               p.category_id, c.name AS category_name,
               COALESCE(array_agg(t.id ORDER BY t.id) FILTER (WHERE t.id IS NOT NULL), '{}') AS tag_ids,
               COALESCE(array_agg(t.name ORDER BY t.id) FILTER (WHERE t.id IS NOT NULL), '{}') AS tag_names,
               ST_X(p.location) AS longitude, ST_Y(p.location) AS latitude
        FROM discovery.places p
        JOIN discovery.neighborhoods n ON n.id = p.neighborhood_id
        JOIN discovery.categories c ON c.id = p.category_id
        LEFT JOIN discovery.place_tags pt ON pt.place_id = p.id
        LEFT JOIN discovery.tags t ON t.id = pt.tag_id
        GROUP BY p.id, p.name, p.neighborhood_id, n.name, p.category_id, c.name, p.location
        ORDER BY p.id
    """

    def __init__(self, pool: asyncpg.Pool, cache_seconds: int = 30) -> None:
        self._pool = pool
        self._cache_seconds = cache_seconds
        self._cached_at = 0.0
        self._cache: tuple[PlaceCandidate, ...] = ()
        self._lock = asyncio.Lock()

    async def get_places(self) -> tuple[PlaceCandidate, ...]:
        now = time.monotonic()
        if self._cache and now - self._cached_at < self._cache_seconds:
            return self._cache
        async with self._lock:
            now = time.monotonic()
            if self._cache and now - self._cached_at < self._cache_seconds:
                return self._cache
            rows = await self._pool.fetch(self._QUERY)
            self._cache = tuple(
                PlaceCandidate(
                    id=row["id"],
                    name=row["name"],
                    neighborhood_id=row["neighborhood_id"],
                    neighborhood_name=row["neighborhood_name"],
                    category_id=row["category_id"],
                    category_name=row["category_name"],
                    tag_ids=tuple(row["tag_ids"]),
                    tag_names=tuple(row["tag_names"]),
                    longitude=row["longitude"],
                    latitude=row["latitude"],
                )
                for row in rows
            )
            self._cached_at = now
            return self._cache

    async def is_ready(self) -> bool:
        try:
            return await self._pool.fetchval("SELECT to_regclass('discovery.places') IS NOT NULL")
        except (asyncpg.PostgresError, OSError):
            return False
