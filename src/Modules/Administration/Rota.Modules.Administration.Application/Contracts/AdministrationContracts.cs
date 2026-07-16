using System.ComponentModel.DataAnnotations;

namespace Rota.Modules.Administration.Application.Contracts;

public sealed record RankedUsageResponse(Guid Id, string Name, long Count);

public sealed record AdministrationDashboardResponse(
    long UserCount,
    long NeighborhoodCount,
    long PlaceCount,
    long RecommendationCount,
    long CompletedRecommendationCount,
    long FailedRecommendationCount,
    double RecommendationSuccessRate,
    double? AverageRecommendationDurationMilliseconds,
    long TripCount,
    long PlannedTripCount,
    long CompletedTripCount,
    long CancelledTripCount,
    long FailedOutboxMessageCount,
    IReadOnlyList<RankedUsageResponse> TopNeighborhoods,
    IReadOnlyList<RankedUsageResponse> TopPlaces,
    DateTimeOffset GeneratedAt);

public sealed class RecommendationSimulationRequest : IValidatableObject
{
    public DateOnly TripDate { get; init; } = DateOnly.FromDateTime(DateTime.UtcNow);

    [Range(-180, 180)]
    public double? StartLongitude { get; init; }

    [Range(-90, 90)]
    public double? StartLatitude { get; init; }

    [Range(60, 720)]
    public int AvailableMinutes { get; init; } = 480;

    [MaxLength(20)]
    public IReadOnlyList<Guid> PreferredCategoryIds { get; init; } = [];

    [MaxLength(30)]
    public IReadOnlyList<Guid> PreferredTagIds { get; init; } = [];

    [MaxLength(20)]
    public IReadOnlyList<string> DietaryPreferences { get; init; } = [];

    [Required, StringLength(40)]
    public string BudgetLevel { get; init; } = "Moderate";

    [Required, StringLength(40)]
    public string TravelPace { get; init; } = "Balanced";

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (StartLongitude.HasValue != StartLatitude.HasValue)
            yield return new ValidationResult(
                "Başlangıç longitude ve latitude değerleri birlikte gönderilmelidir.",
                [nameof(StartLongitude), nameof(StartLatitude)]);
        if (PreferredCategoryIds.Any(id => id == Guid.Empty) || PreferredTagIds.Any(id => id == Guid.Empty))
            yield return new ValidationResult("Tercih kimlikleri boş olamaz.");
        if (DietaryPreferences.Any(item => string.IsNullOrWhiteSpace(item) || item.Length > 80))
            yield return new ValidationResult("Beslenme tercihleri boş olamaz ve 80 karakteri aşamaz.");
    }
}

public sealed record SimulationRegionResponse(Guid NeighborhoodId, string Name, double Score, string Explanation);
public sealed record SimulationPlaceResponse(Guid PlaceId, string Name, double Score, string Explanation);
public sealed record SimulationTimelineResponse(
    int Sequence,
    Guid PlaceId,
    string PlaceName,
    TimeOnly StartTime,
    int DurationMinutes,
    string Explanation);

public sealed record RecommendationSimulationResponse(
    Guid SimulationId,
    string ModelVersion,
    SimulationRegionResponse Region,
    IReadOnlyList<SimulationPlaceResponse> Places,
    IReadOnlyList<SimulationTimelineResponse> Timeline,
    string OverallExplanation,
    bool Persisted,
    DateTimeOffset GeneratedAt);

public interface IAdministrationDashboardService
{
    Task<AdministrationDashboardResponse> GetAsync(CancellationToken cancellationToken = default);
}

public interface IRecommendationSimulationService
{
    Task<RecommendationSimulationResponse> SimulateAsync(
        RecommendationSimulationRequest request,
        string correlationId,
        CancellationToken cancellationToken = default);
}
