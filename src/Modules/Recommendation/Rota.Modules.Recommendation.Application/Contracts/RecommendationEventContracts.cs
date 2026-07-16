namespace Rota.Modules.Recommendation.Application.Contracts;

public sealed record RecommendationCompletedEvent(
    Guid UserId,
    Guid RunId,
    DateOnly TripDate,
    Guid NeighborhoodId,
    string RegionName,
    DateTimeOffset CompletedAt);

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
