using Rota.Modules.Trip.Domain.Entities;

namespace Rota.Modules.Trip.Application.Contracts;

public sealed record TripStopResponse(
    int Sequence,
    Guid PlaceId,
    string PlaceName,
    TimeOnly StartTime,
    int DurationMinutes,
    string Explanation,
    double Longitude,
    double Latitude);

public sealed record TripResponse(
    Guid Id,
    Guid SourceRecommendationRunId,
    DateOnly TripDate,
    int AvailableMinutes,
    Guid NeighborhoodId,
    string RegionName,
    string OverallExplanation,
    TripStatus Status,
    DateTimeOffset CreatedAt,
    DateTimeOffset UpdatedAt,
    IReadOnlyList<TripStopResponse> Stops);

public sealed record TripSummaryResponse(
    Guid Id,
    DateOnly TripDate,
    string RegionName,
    TripStatus Status,
    int StopCount,
    DateTimeOffset CreatedAt);

public sealed record TripPageResponse(
    IReadOnlyList<TripSummaryResponse> Items,
    int Page,
    int PageSize,
    int TotalCount);

public interface ITripService
{
    Task<TripPageResponse> GetPageAsync(Guid userId, int page, int pageSize, CancellationToken cancellationToken = default);
    Task<TripResponse> GetAsync(Guid userId, Guid tripId, CancellationToken cancellationToken = default);
    Task<TripResponse> CancelAsync(Guid userId, Guid tripId, CancellationToken cancellationToken = default);
    Task<TripResponse> CompleteAsync(Guid userId, Guid tripId, CancellationToken cancellationToken = default);
}
