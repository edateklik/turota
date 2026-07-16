using Rota.Modules.Recommendation.Application.Contracts;
using Rota.Modules.Recommendation.Application.Errors;
using Rota.Modules.Recommendation.Domain.Entities;

namespace Rota.Modules.Recommendation.Application.Services;

public sealed class RecommendationOrchestrator(
    IRecommendationService recommendationService,
    ITasteProfileProvider tasteProfileProvider,
    IRecommendationRepository repository,
    IRecommendationEventPublisher eventPublisher,
    TimeProvider timeProvider) : IRecommendationOrchestrator
{
    public async Task<RecommendationResponse> GenerateAsync(
        Guid userId,
        GenerateRecommendationRequest request,
        string correlationId,
        CancellationToken cancellationToken = default)
    {
        Validate(request, DateOnly.FromDateTime(timeProvider.GetUtcNow().UtcDateTime));
        var tasteProfile = await tasteProfileProvider.GetAsync(userId, cancellationToken);
        var runId = Guid.NewGuid();
        var run = RecommendationRun.CreatePending(runId, userId, request.TripDate, correlationId, timeProvider.GetUtcNow());
        await repository.AddAsync(run, cancellationToken);
        await repository.SaveChangesAsync(cancellationToken);

        try
        {
            var aiRequest = new AiRecommendationRequest(
                runId,
                correlationId,
                userId,
                request.TripDate,
                request.AvailableMinutes,
                request.StartLongitude.HasValue
                    ? new GeoPointInput(request.StartLongitude.Value, request.StartLatitude!.Value)
                    : null,
                tasteProfile);
            var result = await recommendationService.GenerateAsync(aiRequest, cancellationToken);
            run.Complete(
                result.ModelVersion,
                result.Region.NeighborhoodId,
                result.Region.Name,
                result.Region.Score,
                result.Region.Explanation,
                result.OverallExplanation,
                result.Places.Select((place, index) => new RecommendedPlace(
                    runId, index + 1, place.PlaceId, place.Name, place.Score, place.Explanation)),
                result.Timeline.Select(item => new RecommendationTimelineItem(
                    runId, item.Sequence, item.PlaceId, item.PlaceName, item.StartTime, item.DurationMinutes, item.Explanation)),
                timeProvider.GetUtcNow());
            await repository.SaveChangesAsync(cancellationToken);
            await eventPublisher.PublishCompletedAsync(new RecommendationCompletedEvent(
                userId,
                run.Id,
                run.TripDate,
                run.NeighborhoodId!.Value,
                run.RegionName!,
                run.CompletedAt!.Value), CancellationToken.None);
            return Map(run);
        }
        catch (Exception exception)
        {
            var code = exception is RecommendationIntegrationException integrationException
                ? integrationException.ErrorCode
                : "RECOMMENDATION_FAILED";
            run.Fail(code, timeProvider.GetUtcNow());
            await repository.SaveChangesAsync(CancellationToken.None);
            await eventPublisher.PublishFailedAsync(new RecommendationFailedEvent(
                userId,
                run.Id,
                run.TripDate,
                code,
                run.CompletedAt!.Value), CancellationToken.None);
            throw;
        }
    }

    public async Task<RecommendationResponse> GetAsync(Guid userId, Guid runId, CancellationToken cancellationToken = default)
    {
        var run = await repository.GetAsync(runId, cancellationToken);
        if (run is null || run.UserId != userId || run.Status != RecommendationRunStatus.Completed)
            throw new KeyNotFoundException("Öneri sonucu bulunamadı.");
        return Map(run);
    }

    public async Task<RecommendationResponse> GetLatestAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var run = await repository.GetLatestAsync(userId, cancellationToken)
            ?? throw new KeyNotFoundException("Tamamlanmış öneri sonucu bulunamadı.");
        return Map(run);
    }

    private static void Validate(GenerateRecommendationRequest request, DateOnly today)
    {
        if (request.AvailableMinutes is < 60 or > 720)
            throw new ArgumentOutOfRangeException(nameof(request.AvailableMinutes), "Kullanılabilir süre 60-720 dakika aralığında olmalıdır.");
        if (request.TripDate < today.AddDays(-1) || request.TripDate > today.AddYears(1))
            throw new ArgumentOutOfRangeException(nameof(request.TripDate), "Rota tarihi bugünden en fazla bir yıl sonrası olabilir.");
        if (request.StartLongitude.HasValue != request.StartLatitude.HasValue)
            throw new ArgumentException("Başlangıç boylamı ve enlemi birlikte verilmelidir.");
        if (request.StartLongitude is < -180 or > 180 || request.StartLatitude is < -90 or > 90)
            throw new ArgumentOutOfRangeException(nameof(request.StartLongitude), "Geçersiz WGS84 başlangıç koordinatı.");
    }

    private static RecommendationResponse Map(RecommendationRun run) => new(
        run.Id,
        run.Status.ToString(),
        run.TripDate,
        new RegionRecommendationResponse(
            run.NeighborhoodId!.Value,
            run.RegionName!,
            run.RegionScore!.Value,
            run.RegionExplanation!),
        run.Places.OrderBy(x => x.Order).Select(x =>
            new PlaceRecommendationResponse(x.Order, x.PlaceId, x.Name, x.Score, x.Explanation)).ToList(),
        run.Timeline.OrderBy(x => x.Sequence).Select(x =>
            new TimelineRecommendationResponse(x.Sequence, x.PlaceId, x.PlaceName, x.StartTime, x.DurationMinutes, x.Explanation)).ToList(),
        run.OverallExplanation!,
        run.ModelVersion!,
        run.CompletedAt!.Value);
}
