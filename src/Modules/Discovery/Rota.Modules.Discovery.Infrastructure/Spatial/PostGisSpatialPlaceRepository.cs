using Microsoft.EntityFrameworkCore;
using Npgsql;
using Rota.Modules.Discovery.Application.Spatial;
using Rota.Modules.Discovery.Infrastructure.Persistence;

namespace Rota.Modules.Discovery.Infrastructure.Spatial;

public sealed class PostGisSpatialPlaceRepository(DiscoveryDbContext dbContext) : ISpatialPlaceRepository
{
    public async Task<IReadOnlyList<SpatialPlaceResult>> GetInsideNeighborhoodAsync(
        Guid neighborhoodId,
        CancellationToken cancellationToken = default)
    {
        const string sql = """
            SELECT p.id AS "Id", p.name AS "Name", p.address AS "Address",
                   p.neighborhood_id AS "NeighborhoodId", p.category_id AS "CategoryId",
                   ST_X(p.location) AS "Longitude", ST_Y(p.location) AS "Latitude",
                   NULL::double precision AS "DistanceMeters"
            FROM discovery.places AS p
            INNER JOIN discovery.neighborhoods AS n ON n.id = p.neighborhood_id
            WHERE n.id = @neighborhoodId AND ST_Covers(n.boundary, p.location)
            ORDER BY p.name
            """;

        var rows = await dbContext.Database.SqlQueryRaw<SpatialPlaceRow>(
                sql,
                new NpgsqlParameter<Guid>("neighborhoodId", neighborhoodId))
            .ToListAsync(cancellationToken);
        return rows.Select(Map).ToList();
    }

    public async Task<IReadOnlyList<SpatialPlaceResult>> GetNearestAsync(
        double longitude,
        double latitude,
        int limit,
        CancellationToken cancellationToken = default)
    {
        const string sql = """
            SELECT p.id AS "Id", p.name AS "Name", p.address AS "Address",
                   p.neighborhood_id AS "NeighborhoodId", p.category_id AS "CategoryId",
                   ST_X(p.location) AS "Longitude", ST_Y(p.location) AS "Latitude",
                   ST_Distance(
                       p.location::geography,
                       ST_SetSRID(ST_MakePoint(@longitude, @latitude), 4326)::geography
                   ) AS "DistanceMeters"
            FROM discovery.places AS p
            ORDER BY p.location <-> ST_SetSRID(ST_MakePoint(@longitude, @latitude), 4326)
            LIMIT @limit
            """;

        var rows = await dbContext.Database.SqlQueryRaw<SpatialPlaceRow>(sql, Parameters(longitude, latitude, limit))
            .ToListAsync(cancellationToken);
        return rows.Select(Map).ToList();
    }

    public async Task<IReadOnlyList<SpatialPlaceResult>> GetWithinRadiusAsync(
        double longitude,
        double latitude,
        double radiusMeters,
        int limit,
        CancellationToken cancellationToken = default)
    {
        const string sql = """
            SELECT p.id AS "Id", p.name AS "Name", p.address AS "Address",
                   p.neighborhood_id AS "NeighborhoodId", p.category_id AS "CategoryId",
                   ST_X(p.location) AS "Longitude", ST_Y(p.location) AS "Latitude",
                   ST_Distance(
                       p.location::geography,
                       ST_SetSRID(ST_MakePoint(@longitude, @latitude), 4326)::geography
                   ) AS "DistanceMeters"
            FROM discovery.places AS p
            WHERE ST_DWithin(
                p.location::geography,
                ST_SetSRID(ST_MakePoint(@longitude, @latitude), 4326)::geography,
                @radiusMeters
            )
            ORDER BY p.location <-> ST_SetSRID(ST_MakePoint(@longitude, @latitude), 4326)
            LIMIT @limit
            """;

        var parameters = Parameters(longitude, latitude, limit)
            .Append(new NpgsqlParameter<double>("radiusMeters", radiusMeters))
            .ToArray();
        var rows = await dbContext.Database.SqlQueryRaw<SpatialPlaceRow>(sql, parameters)
            .ToListAsync(cancellationToken);
        return rows.Select(Map).ToList();
    }

    public async Task<IReadOnlyList<SpatialNeighborhoodResult>> GetNearbyNeighborhoodsAsync(
        double longitude,
        double latitude,
        int limit,
        CancellationToken cancellationToken = default)
    {
        const string sql = """
            SELECT n.id AS "Id", n.name AS "Name", n.city_id AS "CityId",
                   ST_Distance(
                       n.boundary::geography,
                       ST_SetSRID(ST_MakePoint(@longitude, @latitude), 4326)::geography
                   ) AS "DistanceMeters"
            FROM discovery.neighborhoods AS n
            ORDER BY n.boundary <-> ST_SetSRID(ST_MakePoint(@longitude, @latitude), 4326)
            LIMIT @limit
            """;

        var rows = await dbContext.Database.SqlQueryRaw<SpatialNeighborhoodRow>(sql, Parameters(longitude, latitude, limit))
            .ToListAsync(cancellationToken);
        return rows.Select(x => new SpatialNeighborhoodResult(x.Id, x.Name, x.CityId, x.DistanceMeters)).ToList();
    }

    private static object[] Parameters(double longitude, double latitude, int limit) =>
    [
        new NpgsqlParameter<double>("longitude", longitude),
        new NpgsqlParameter<double>("latitude", latitude),
        new NpgsqlParameter<int>("limit", limit)
    ];

    private static SpatialPlaceResult Map(SpatialPlaceRow row) => new(
        row.Id,
        row.Name,
        row.Address,
        row.NeighborhoodId,
        row.CategoryId,
        row.Longitude,
        row.Latitude,
        row.DistanceMeters);

    private sealed class SpatialPlaceRow
    {
        public Guid Id { get; init; }
        public string Name { get; init; } = null!;
        public string Address { get; init; } = null!;
        public Guid NeighborhoodId { get; init; }
        public Guid CategoryId { get; init; }
        public double Longitude { get; init; }
        public double Latitude { get; init; }
        public double? DistanceMeters { get; init; }
    }

    private sealed class SpatialNeighborhoodRow
    {
        public Guid Id { get; init; }
        public string Name { get; init; } = null!;
        public Guid CityId { get; init; }
        public double DistanceMeters { get; init; }
    }
}
