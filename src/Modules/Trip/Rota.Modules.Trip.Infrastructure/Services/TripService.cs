using Microsoft.EntityFrameworkCore;
using Rota.Modules.Trip.Application.Contracts;
using Rota.Modules.Trip.Application.Errors;
using Rota.Modules.Trip.Domain.Entities;
using Rota.Modules.Trip.Infrastructure.Persistence;

namespace Rota.Modules.Trip.Infrastructure.Services;

public sealed class TripService(TripDbContext dbContext, TimeProvider timeProvider) : ITripService
{
    public async Task<TripPageResponse> GetPageAsync(
        Guid userId,
        int page,
        int pageSize,
        CancellationToken cancellationToken = default)
    {
        if (page < 1 || pageSize is < 1 or > 50) throw new ArgumentException("Sayfa en az 1, sayfa boyutu 1-50 olmalıdır.");
        var query = dbContext.Trips.AsNoTracking().Where(trip => trip.UserId == userId);
        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query.OrderByDescending(trip => trip.TripDate).ThenByDescending(trip => trip.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(trip => new TripSummaryResponse(
                trip.Id,
                trip.TripDate,
                trip.RegionName,
                trip.Status,
                trip.Stops.Count,
                trip.CreatedAt))
            .ToListAsync(cancellationToken);
        return new TripPageResponse(items, page, pageSize, totalCount);
    }

    public async Task<TripResponse> GetAsync(Guid userId, Guid tripId, CancellationToken cancellationToken = default) =>
        Map(await FindAsync(userId, tripId, cancellationToken));

    public Task<TripResponse> CancelAsync(Guid userId, Guid tripId, CancellationToken cancellationToken = default) =>
        ChangeStatusAsync(userId, tripId, complete: false, cancellationToken);

    public Task<TripResponse> CompleteAsync(Guid userId, Guid tripId, CancellationToken cancellationToken = default) =>
        ChangeStatusAsync(userId, tripId, complete: true, cancellationToken);

    private async Task<TripResponse> ChangeStatusAsync(Guid userId, Guid tripId, bool complete, CancellationToken cancellationToken)
    {
        var trip = await FindAsync(userId, tripId, cancellationToken);
        try
        {
            if (complete) trip.Complete(timeProvider.GetUtcNow());
            else trip.Cancel(timeProvider.GetUtcNow());
        }
        catch (InvalidOperationException exception)
        {
            throw new TripStateConflictException(exception.Message);
        }

        await dbContext.SaveChangesAsync(cancellationToken);
        return Map(trip);
    }

    private async Task<Domain.Entities.Trip> FindAsync(Guid userId, Guid tripId, CancellationToken cancellationToken) =>
        await dbContext.Trips.Include(trip => trip.Stops)
            .SingleOrDefaultAsync(trip => trip.Id == tripId && trip.UserId == userId, cancellationToken)
        ?? throw new KeyNotFoundException("Rota bulunamadı.");

    private static TripResponse Map(Domain.Entities.Trip trip) => new(
        trip.Id,
        trip.SourceRecommendationRunId,
        trip.TripDate,
        trip.AvailableMinutes,
        trip.NeighborhoodId,
        trip.RegionName,
        trip.OverallExplanation,
        trip.Status,
        trip.CreatedAt,
        trip.UpdatedAt,
        trip.Stops.OrderBy(stop => stop.Sequence).Select(stop => new TripStopResponse(
            stop.Sequence,
            stop.PlaceId,
            stop.PlaceName,
            stop.StartTime,
            stop.DurationMinutes,
            stop.Explanation,
            stop.Longitude,
            stop.Latitude)).ToList());
}
