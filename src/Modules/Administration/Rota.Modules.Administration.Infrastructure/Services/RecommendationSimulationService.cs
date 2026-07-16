using Rota.Modules.Administration.Application.Contracts;
using Rota.Modules.Recommendation.Application.Contracts;

namespace Rota.Modules.Administration.Infrastructure.Services;

public sealed class RecommendationSimulationService(
    IRecommendationService recommendationService,
    TimeProvider timeProvider) : IRecommendationSimulationService
{
    public async Task<RecommendationSimulationResponse> SimulateAsync(
        RecommendationSimulationRequest request,
        string correlationId,
        CancellationToken cancellationToken = default)
    {
        var simulationId = Guid.NewGuid();
        var result = await recommendationService.GenerateAsync(
            new AiRecommendationRequest(
                simulationId,
                correlationId,
                Guid.Empty,
                request.TripDate,
                request.AvailableMinutes,
                request.StartLongitude.HasValue
                    ? new GeoPointInput(request.StartLongitude.Value, request.StartLatitude!.Value)
                    : null,
                new TasteProfileSnapshot(
                    request.PreferredCategoryIds.Distinct().ToArray(),
                    request.PreferredTagIds.Distinct().ToArray(),
                    request.DietaryPreferences.Select(item => item.Trim()).Distinct(StringComparer.OrdinalIgnoreCase).ToArray(),
                    request.BudgetLevel.Trim(),
                    request.TravelPace.Trim())),
            cancellationToken);

        return new RecommendationSimulationResponse(
            simulationId,
            result.ModelVersion,
            new SimulationRegionResponse(
                result.Region.NeighborhoodId,
                result.Region.Name,
                result.Region.Score,
                result.Region.Explanation),
            result.Places.Select(item => new SimulationPlaceResponse(
                item.PlaceId,
                item.Name,
                item.Score,
                item.Explanation)).ToList(),
            result.Timeline.Select(item => new SimulationTimelineResponse(
                item.Sequence,
                item.PlaceId,
                item.PlaceName,
                item.StartTime,
                item.DurationMinutes,
                item.Explanation)).ToList(),
            result.OverallExplanation,
            Persisted: false,
            timeProvider.GetUtcNow());
    }
}
