using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Rota.Modules.Recommendation.Infrastructure.Workers;

public sealed class RecommendationBackgroundWorker(
    IServiceScopeFactory scopeFactory,
    RecommendationWorkerOptions options,
    ILogger<RecommendationBackgroundWorker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await using var scope = scopeFactory.CreateAsyncScope();
                var processor = scope.ServiceProvider.GetRequiredService<RecommendationJobProcessor>();
                var processed = await processor.ProcessNextAsync(stoppingToken);
                if (!processed)
                    await Task.Delay(options.PollIntervalMilliseconds, stoppingToken);
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception exception)
            {
                logger.LogError(exception, "Recommendation background worker döngüsü başarısız oldu.");
                await Task.Delay(options.PollIntervalMilliseconds, stoppingToken);
            }
        }
    }
}
