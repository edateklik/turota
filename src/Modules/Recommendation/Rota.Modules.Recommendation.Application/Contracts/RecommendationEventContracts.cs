namespace Rota.Modules.Recommendation.Application.Contracts;

public sealed record RecommendationCompletedEvent(
    Guid UserId,
    Guid RunId,
    DateOnly TripDate,
    int AvailableMinutes,
    Guid NeighborhoodId,
    string RegionName,
    string OverallExplanation,
    IReadOnlyList<RecommendationTimelineEventItem> Timeline,
    DateTimeOffset CompletedAt);

public sealed record RecommendationTimelineEventItem(
    int Sequence,
    Guid PlaceId,
    string PlaceName,
    TimeOnly StartTime,
    int DurationMinutes,
    string Explanation);

public sealed record RecommendationFailedEvent(
    Guid UserId,
    Guid RunId,
    DateOnly TripDate,
    string ErrorCode,
    DateTimeOffset FailedAt);

public interface IRecommendationEventPublisher
{
    Task PublishCompletedAsync(RecommendationCompletedEvent notification, CancellationToken cancellationToken = default);
    Task PublishFailedAsync(RecommendationFailedEvent notification, CancellationToken cancellationToken = default);
}

/// <summary>Outbox olaylarını bağımsız modül tüketicilerine dağıtır.</summary>
public interface IRecommendationEventHandler
{
    Task HandleCompletedAsync(RecommendationCompletedEvent notification, CancellationToken cancellationToken = default);
    Task HandleFailedAsync(RecommendationFailedEvent notification, CancellationToken cancellationToken = default);
}
