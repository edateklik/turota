using Rota.Modules.Recommendation.Application.Contracts;

namespace Rota.Modules.Recommendation.Infrastructure.Outbox;

public sealed class CompositeRecommendationEventPublisher(
    IEnumerable<IRecommendationEventHandler> handlers) : IRecommendationEventPublisher
{
    public async Task PublishCompletedAsync(
        RecommendationCompletedEvent notification,
        CancellationToken cancellationToken = default)
    {
        foreach (var handler in handlers)
            await handler.HandleCompletedAsync(notification, cancellationToken);
    }

    public async Task PublishFailedAsync(
        RecommendationFailedEvent notification,
        CancellationToken cancellationToken = default)
    {
        foreach (var handler in handlers)
            await handler.HandleFailedAsync(notification, cancellationToken);
    }
}
