namespace Rota.Modules.Discovery.Application.Spatial;

public sealed class PlaceDiscoveryService(ISpatialPlaceRepository repository) : IPlaceDiscoveryService
{
    private const int MaxPlaceResultCount = 100;
    private const int MaxNeighborhoodResultCount = 5;
    private const double MaxRadiusKilometers = 50;

    public Task<IReadOnlyList<SpatialPlaceResult>> GetInsideNeighborhoodAsync(
        Guid neighborhoodId,
        CancellationToken cancellationToken = default)
    {
        if (neighborhoodId == Guid.Empty)
            throw new ArgumentException("Mahalle kimliği boş olamaz.", nameof(neighborhoodId));

        return repository.GetInsideNeighborhoodAsync(neighborhoodId, cancellationToken);
    }

    public Task<IReadOnlyList<SpatialPlaceResult>> GetNearestAsync(
        double longitude,
        double latitude,
        int limit = 20,
        CancellationToken cancellationToken = default)
    {
        ValidateCoordinate(longitude, latitude);
        return repository.GetNearestAsync(longitude, latitude, ClampLimit(limit, MaxPlaceResultCount), cancellationToken);
    }

    public Task<IReadOnlyList<SpatialPlaceResult>> GetWithinRadiusAsync(
        double longitude,
        double latitude,
        double radiusKilometers,
        int limit = 100,
        CancellationToken cancellationToken = default)
    {
        ValidateCoordinate(longitude, latitude);
        if (radiusKilometers is <= 0 or > MaxRadiusKilometers)
            throw new ArgumentOutOfRangeException(nameof(radiusKilometers), $"Yarıçap 0-{MaxRadiusKilometers} km aralığında olmalıdır.");

        return repository.GetWithinRadiusAsync(
            longitude,
            latitude,
            radiusKilometers * 1_000,
            ClampLimit(limit, MaxPlaceResultCount),
            cancellationToken);
    }

    public Task<IReadOnlyList<SpatialNeighborhoodResult>> GetNearbyNeighborhoodsAsync(
        double longitude,
        double latitude,
        int limit = MaxNeighborhoodResultCount,
        CancellationToken cancellationToken = default)
    {
        ValidateCoordinate(longitude, latitude);
        return repository.GetNearbyNeighborhoodsAsync(
            longitude,
            latitude,
            ClampLimit(limit, MaxNeighborhoodResultCount),
            cancellationToken);
    }

    private static int ClampLimit(int limit, int maximum)
    {
        if (limit <= 0)
            throw new ArgumentOutOfRangeException(nameof(limit), "Sonuç limiti pozitif olmalıdır.");
        return Math.Min(limit, maximum);
    }

    private static void ValidateCoordinate(double longitude, double latitude)
    {
        if (longitude is < -180 or > 180)
            throw new ArgumentOutOfRangeException(nameof(longitude), "Boylam -180 ile 180 arasında olmalıdır.");
        if (latitude is < -90 or > 90)
            throw new ArgumentOutOfRangeException(nameof(latitude), "Enlem -90 ile 90 arasında olmalıdır.");
    }
}
