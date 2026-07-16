using System.Text.Json;
using Rota.Modules.Recommendation.Application.Contracts;
using Rota.Modules.Recommendation.Domain.Entities;

namespace Rota.Modules.Recommendation.Application.Services;

public sealed class RecommendationOrchestrator(
    ITasteProfileProvider tasteProfileProvider,
    IRecommendationRepository repository,
    TimeProvider timeProvider) : IRecommendationOrchestrator
{
    public async Task<RecommendationAcceptedResponse> EnqueueAsync(
        Guid userId,
        GenerateRecommendationRequest request,
        string correlationId,
        CancellationToken cancellationToken = default)
    {
        Validate(request, DateOnly.FromDateTime(timeProvider.GetUtcNow().UtcDateTime));
        var tasteProfile = await tasteProfileProvider.GetAsync(userId, cancellationToken);
        var runId = Guid.NewGuid();
        var requestedAt = timeProvider.GetUtcNow();
        var run = RecommendationRun.CreatePending(
            runId,
            userId,
            request.TripDate,
            correlationId,
            new RecommendationRequestData(
                request.AvailableMinutes,
                request.StartLongitude,
                request.StartLatitude,
                JsonSerializer.Serialize(tasteProfile)),
            requestedAt);
        await repository.AddAsync(run, cancellationToken);
        await repository.SaveChangesAsync(cancellationToken);

        return new RecommendationAcceptedResponse(
            run.Id,
            run.Status.ToString(),
            $"/api/recommendations/{run.Id}",
            requestedAt);
    }

    public async Task<RecommendationRunResponse> GetAsync(
        Guid userId,
        Guid runId,
        CancellationToken cancellationToken = default)
    {
        var run = await repository.GetAsync(runId, cancellationToken);
        if (run is null || run.UserId != userId)
            throw new KeyNotFoundException("Öneri çalışması bulunamadı.");

        return new RecommendationRunResponse(
            run.Id,
            run.Status.ToString(),
            run.TripDate,
            run.AttemptCount,
            run.RequestedAt,
            run.CompletedAt,
            run.FailureCode,
            run.Status == RecommendationRunStatus.Completed ? MapCompleted(run) : null);
    }

    public async Task<RecommendationResponse> GetLatestAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var run = await repository.GetLatestAsync(userId, cancellationToken)
            ?? throw new KeyNotFoundException("Tamamlanmış öneri sonucu bulunamadı.");
        return MapCompleted(run);
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

    internal static RecommendationResponse MapCompleted(RecommendationRun run) => new(
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
