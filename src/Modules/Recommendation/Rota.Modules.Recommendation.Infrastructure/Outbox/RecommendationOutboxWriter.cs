using System.Text.Json;
using Rota.Modules.Recommendation.Application.Contracts;
using Rota.Modules.Recommendation.Infrastructure.Persistence;

namespace Rota.Modules.Recommendation.Infrastructure.Outbox;

public sealed class RecommendationOutboxWriter(
    RecommendationDbContext dbContext,
    TimeProvider timeProvider)
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    public void Add(RecommendationCompletedEvent message) =>
        Add(message.RunId, RecommendationOutboxTypes.Completed, message);

    public void Add(RecommendationFailedEvent message) =>
        Add(message.RunId, RecommendationOutboxTypes.Failed, message);

    private void Add<T>(Guid aggregateId, string type, T message) =>
        dbContext.OutboxMessages.Add(RecommendationOutboxMessage.Create(
            aggregateId,
            type,
            JsonSerializer.Serialize(message, JsonOptions),
            timeProvider.GetUtcNow()));
}

public static class RecommendationOutboxTypes
{
    public const string Completed = "recommendation.completed.v1";
    public const string Failed = "recommendation.failed.v1";
}
