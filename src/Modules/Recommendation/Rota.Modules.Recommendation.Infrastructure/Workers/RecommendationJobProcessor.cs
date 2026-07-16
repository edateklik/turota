using System.Text.Json;
using Microsoft.Extensions.Logging;
using Rota.Modules.Recommendation.Application.Contracts;
using Rota.Modules.Recommendation.Application.Errors;
using Rota.Modules.Recommendation.Domain.Entities;
using Rota.Modules.Recommendation.Infrastructure.Outbox;

namespace Rota.Modules.Recommendation.Infrastructure.Workers;

public sealed class RecommendationJobProcessor(
    IRecommendationService recommendationService,
    IRecommendationRepository repository,
    RecommendationOutboxWriter outboxWriter,
    RecommendationWorkerOptions options,
    TimeProvider timeProvider,
    ILogger<RecommendationJobProcessor> logger)
{
    public async Task<bool> ProcessNextAsync(CancellationToken cancellationToken)
    {
        var run = await repository.ClaimNextAsync(
            timeProvider.GetUtcNow(),
            TimeSpan.FromSeconds(options.LeaseSeconds),
            cancellationToken);
        if (run is null) return false;

        try
        {
            var tasteProfile = JsonSerializer.Deserialize<TasteProfileSnapshot>(run.TasteProfileJson)
                ?? throw new InvalidOperationException("Kaydedilmiş TasteProfile snapshot okunamadı.");
            var request = new AiRecommendationRequest(
                run.Id,
                run.CorrelationId,
                run.UserId,
                run.TripDate,
                run.AvailableMinutes,
                run.StartLongitude.HasValue
                    ? new GeoPointInput(run.StartLongitude.Value, run.StartLatitude!.Value)
                    : null,
                tasteProfile);
            var result = await recommendationService.GenerateAsync(request, cancellationToken);
            run.Complete(
                result.ModelVersion,
                result.Region.NeighborhoodId,
                result.Region.Name,
                result.Region.Score,
                result.Region.Explanation,
                result.OverallExplanation,
                result.Places.Select((place, index) => new RecommendedPlace(
                    run.Id, index + 1, place.PlaceId, place.Name, place.Score, place.Explanation)),
                result.Timeline.Select(item => new RecommendationTimelineItem(
                    run.Id, item.Sequence, item.PlaceId, item.PlaceName, item.StartTime, item.DurationMinutes, item.Explanation)),
                timeProvider.GetUtcNow());
            outboxWriter.Add(new RecommendationCompletedEvent(
                run.UserId,
                run.Id,
                run.TripDate,
                run.NeighborhoodId!.Value,
                run.RegionName!,
                run.CompletedAt!.Value));
            await repository.SaveChangesAsync(cancellationToken);
        }
        catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
        {
            run.ScheduleRetry("WORKER_STOPPED", timeProvider.GetUtcNow());
            await repository.SaveChangesAsync(CancellationToken.None);
            throw;
        }
        catch (Exception exception)
        {
            var errorCode = exception is RecommendationIntegrationException integrationException
                ? integrationException.ErrorCode
                : "RECOMMENDATION_FAILED";
            var now = timeProvider.GetUtcNow();
            if (run.AttemptCount < options.MaxAttempts)
            {
                var retryDelay = options.RetryDelayMilliseconds * Math.Pow(2, run.AttemptCount - 1);
                run.ScheduleRetry(errorCode, now.AddMilliseconds(retryDelay));
                logger.LogWarning(exception,
                    "Recommendation job yeniden denenecek. RunId: {RunId}, Attempt: {Attempt}",
                    run.Id,
                    run.AttemptCount);
            }
            else
            {
                run.Fail(errorCode, now);
                outboxWriter.Add(new RecommendationFailedEvent(
                    run.UserId,
                    run.Id,
                    run.TripDate,
                    errorCode,
                    run.CompletedAt!.Value));
                logger.LogError(exception,
                    "Recommendation job kalıcı olarak başarısız. RunId: {RunId}, Attempts: {Attempts}",
                    run.Id,
                    run.AttemptCount);
            }

            await repository.SaveChangesAsync(CancellationToken.None);
        }

        return true;
    }
}
