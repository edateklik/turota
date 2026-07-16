using Microsoft.EntityFrameworkCore;
using Rota.Modules.Discovery.Application.Spatial;
using Rota.Modules.Recommendation.Application.Contracts;
using Rota.Modules.Trip.Domain.Entities;
using Rota.Modules.Trip.Infrastructure.Persistence;

namespace Rota.Modules.Trip.Infrastructure.Events;

public sealed class RecommendationTripEventHandler(
    TripDbContext dbContext,
    IPlaceLocationReader placeLocationReader) : IRecommendationEventHandler
{
    public async Task HandleCompletedAsync(
        RecommendationCompletedEvent notification,
        CancellationToken cancellationToken = default)
    {
        if (await dbContext.Trips.AnyAsync(
                trip => trip.SourceRecommendationRunId == notification.RunId,
                cancellationToken))
            return;

        var placeIds = notification.Timeline.Select(item => item.PlaceId).Distinct().ToArray();
        var locations = await placeLocationReader.GetByIdsAsync(placeIds, cancellationToken);
        var missingIds = placeIds.Where(id => !locations.ContainsKey(id)).ToArray();
        if (missingIds.Length > 0)
            throw new InvalidOperationException($"Timeline mekan koordinatları bulunamadı: {string.Join(',', missingIds)}");

        var trip = new Domain.Entities.Trip(
            Guid.NewGuid(),
            notification.RunId,
            notification.UserId,
            notification.TripDate,
            notification.AvailableMinutes,
            notification.NeighborhoodId,
            notification.RegionName,
            notification.OverallExplanation,
            notification.Timeline.Select(item =>
            {
                var location = locations[item.PlaceId];
                return new TripStop(
                    Guid.NewGuid(),
                    item.Sequence,
                    item.PlaceId,
                    item.PlaceName,
                    item.StartTime,
                    item.DurationMinutes,
                    item.Explanation,
                    location.Longitude,
                    location.Latitude);
            }),
            notification.CompletedAt);
        dbContext.Trips.Add(trip);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public Task HandleFailedAsync(
        RecommendationFailedEvent notification,
        CancellationToken cancellationToken = default) => Task.CompletedTask;
}
