using System.Text.Json;
using Microsoft.Extensions.Logging;
using Rota.Modules.Recommendation.Application.Contracts;

namespace Rota.Modules.Recommendation.Infrastructure.Outbox;

public sealed class RecommendationOutboxDispatcher(
    RecommendationOutboxStore store,
    IRecommendationEventPublisher publisher,
    OutboxWorkerOptions options,
    TimeProvider timeProvider,
    ILogger<RecommendationOutboxDispatcher> logger)
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    public async Task<bool> DispatchNextAsync(CancellationToken cancellationToken)
    {
        var message = await store.ClaimNextAsync(
            timeProvider.GetUtcNow(),
            TimeSpan.FromSeconds(options.LeaseSeconds),
            cancellationToken);
        if (message is null) return false;

        try
        {
            await PublishAsync(message, cancellationToken);
            message.MarkProcessed(timeProvider.GetUtcNow());
            await store.SaveChangesAsync(cancellationToken);
        }
        catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
        {
            message.ScheduleRetry("OUTBOX_WORKER_STOPPED", timeProvider.GetUtcNow());
            await store.SaveChangesAsync(CancellationToken.None);
            throw;
        }
        catch (Exception exception)
        {
            var now = timeProvider.GetUtcNow();
            if (message.AttemptCount < options.MaxAttempts)
            {
                var delay = options.RetryDelayMilliseconds * Math.Pow(2, message.AttemptCount - 1);
                message.ScheduleRetry(exception.Message, now.AddMilliseconds(delay));
                logger.LogWarning(exception,
                    "Outbox mesajı yeniden denenecek. MessageId: {MessageId}, Attempt: {Attempt}",
                    message.Id,
                    message.AttemptCount);
            }
            else
            {
                message.MarkFailed(exception.Message);
                logger.LogError(exception,
                    "Outbox mesajı dead-letter durumuna geçti. MessageId: {MessageId}, Attempts: {Attempts}",
                    message.Id,
                    message.AttemptCount);
            }

            await store.SaveChangesAsync(CancellationToken.None);
        }

        return true;
    }

    private Task PublishAsync(RecommendationOutboxMessage message, CancellationToken cancellationToken) =>
        message.Type switch
        {
            RecommendationOutboxTypes.Completed => publisher.PublishCompletedAsync(
                Deserialize<RecommendationCompletedEvent>(message), cancellationToken),
            RecommendationOutboxTypes.Failed => publisher.PublishFailedAsync(
                Deserialize<RecommendationFailedEvent>(message), cancellationToken),
            _ => throw new InvalidOperationException($"Desteklenmeyen outbox mesaj tipi: {message.Type}")
        };

    private static T Deserialize<T>(RecommendationOutboxMessage message) =>
        JsonSerializer.Deserialize<T>(message.Payload, JsonOptions)
        ?? throw new InvalidOperationException($"Outbox payload okunamadı: {message.Id}");
}
