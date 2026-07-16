namespace Rota.Modules.Discovery.Application.Spatial;

public sealed record SpatialPlaceResult(
    Guid Id,
    string Name,
    string Address,
    Guid NeighborhoodId,
    Guid CategoryId,
    double Longitude,
    double Latitude,
    double? DistanceMeters);

public sealed record SpatialNeighborhoodResult(
    Guid Id,
    string Name,
    Guid CityId,
    double DistanceMeters);

public sealed record PlaceLocationResult(Guid Id, double Longitude, double Latitude);

public interface IPlaceLocationReader
{
    Task<IReadOnlyDictionary<Guid, PlaceLocationResult>> GetByIdsAsync(
        IReadOnlyCollection<Guid> placeIds,
        CancellationToken cancellationToken = default);
}

public interface ISpatialPlaceRepository
{
    Task<IReadOnlyList<SpatialPlaceResult>> GetInsideNeighborhoodAsync(
        Guid neighborhoodId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<SpatialPlaceResult>> GetNearestAsync(
        double longitude,
        double latitude,
        int limit,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<SpatialPlaceResult>> GetWithinRadiusAsync(
        double longitude,
        double latitude,
        double radiusMeters,
        int limit,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<SpatialNeighborhoodResult>> GetNearbyNeighborhoodsAsync(
        double longitude,
        double latitude,
        int limit,
        CancellationToken cancellationToken = default);
}

public interface IPlaceDiscoveryService
{
    Task<IReadOnlyList<SpatialPlaceResult>> GetInsideNeighborhoodAsync(
        Guid neighborhoodId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<SpatialPlaceResult>> GetNearestAsync(
        double longitude,
        double latitude,
        int limit = 20,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<SpatialPlaceResult>> GetWithinRadiusAsync(
        double longitude,
        double latitude,
        double radiusKilometers,
        int limit = 100,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<SpatialNeighborhoodResult>> GetNearbyNeighborhoodsAsync(
        double longitude,
        double latitude,
        int limit = 5,
        CancellationToken cancellationToken = default);
}
