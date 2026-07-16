using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Rota.Modules.Recommendation.Infrastructure.Outbox;

public sealed class RecommendationOutboxBackgroundWorker(
    IServiceScopeFactory scopeFactory,
    OutboxWorkerOptions options,
    TimeProvider timeProvider,
    ILogger<RecommendationOutboxBackgroundWorker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var nextCleanupAt = DateTimeOffset.MinValue;
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await using var scope = scopeFactory.CreateAsyncScope();
                var now = timeProvider.GetUtcNow();
                if (now >= nextCleanupAt)
                {
                    var store = scope.ServiceProvider.GetRequiredService<RecommendationOutboxStore>();
                    await store.DeleteProcessedBeforeAsync(
                        now.AddHours(-options.ProcessedRetentionHours),
                        stoppingToken);
                    nextCleanupAt = now.AddMinutes(options.CleanupIntervalMinutes);
                }
                var dispatcher = scope.ServiceProvider.GetRequiredService<RecommendationOutboxDispatcher>();
                var dispatched = await dispatcher.DispatchNextAsync(stoppingToken);
                if (!dispatched)
                    await Task.Delay(options.PollIntervalMilliseconds, stoppingToken);
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception exception)
            {
                logger.LogError(exception, "Recommendation outbox dispatcher döngüsü başarısız oldu.");
                await Task.Delay(options.PollIntervalMilliseconds, stoppingToken);
            }
        }
    }
}
