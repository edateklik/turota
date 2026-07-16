using Microsoft.EntityFrameworkCore;
using Rota.Modules.Discovery.Infrastructure.Persistence;

namespace Rota.Modules.Discovery.Infrastructure.Quality;

public sealed class DiscoveryDataQualityService(DiscoveryDbContext dbContext)
{
    public async Task<DiscoveryDataQualityReport> CheckAsync(CancellationToken cancellationToken = default)
    {
        var cityCount = await dbContext.Cities.AsNoTracking().CountAsync(cancellationToken);
        var neighborhoodCount = await dbContext.Neighborhoods.AsNoTracking().CountAsync(cancellationToken);
        var placeCount = await dbContext.Places.AsNoTracking().CountAsync(cancellationToken);
        var categoryCount = await dbContext.Categories.AsNoTracking().CountAsync(cancellationToken);
        var tagCount = await dbContext.Tags.AsNoTracking().CountAsync(cancellationToken);
        var invalidBoundaryCount = await dbContext.Neighborhoods.AsNoTracking()
            .CountAsync(x => !x.Boundary.IsValid || x.Boundary.SRID != 4326, cancellationToken);
        var invalidLocationCount = await dbContext.Places.AsNoTracking()
            .CountAsync(x => x.Location.SRID != 4326, cancellationToken);
        var outsideNeighborhoodCount = await dbContext.Places.AsNoTracking()
            .CountAsync(x => !x.Neighborhood.Boundary.Covers(x.Location), cancellationToken);

        var isHealthy = neighborhoodCount >= 3
            && placeCount is >= 30 and <= 50
            && invalidBoundaryCount == 0
            && invalidLocationCount == 0
            && outsideNeighborhoodCount == 0;

        return new DiscoveryDataQualityReport(
            isHealthy,
            cityCount,
            neighborhoodCount,
            placeCount,
            categoryCount,
            tagCount,
            invalidBoundaryCount,
            invalidLocationCount,
            outsideNeighborhoodCount);
    }
}

public sealed record DiscoveryDataQualityReport(
    bool IsHealthy,
    int CityCount,
    int NeighborhoodCount,
    int PlaceCount,
    int CategoryCount,
    int TagCount,
    int InvalidBoundaryCount,
    int InvalidLocationCount,
    int OutsideNeighborhoodCount);
