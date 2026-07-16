using System.ComponentModel.DataAnnotations;
using Rota.Modules.Recommendation.Domain.Entities;

namespace Rota.Modules.Recommendation.Application.Contracts;

/// <summary>AI önerisi oluşturmak için kullanıcı bağlamı.</summary>
public sealed class GenerateRecommendationRequest
{
    /// <summary>Rotanın planlandığı yerel tarih.</summary>
    public DateOnly TripDate { get; init; } = DateOnly.FromDateTime(DateTime.UtcNow);

    /// <summary>Opsiyonel başlangıç boylamı, WGS84.</summary>
    [Range(-180, 180)]
    public double? StartLongitude { get; init; }

    /// <summary>Opsiyonel başlangıç enlemi, WGS84.</summary>
    [Range(-90, 90)]
    public double? StartLatitude { get; init; }

    /// <summary>Günlük rota için kullanılabilir süre; 60-720 dakika.</summary>
    [Range(60, 720)]
    public int AvailableMinutes { get; init; } = 480;
}

public sealed record RecommendationResponse(
    Guid RunId,
    string Status,
    DateOnly TripDate,
    RegionRecommendationResponse Region,
    IReadOnlyList<PlaceRecommendationResponse> Places,
    IReadOnlyList<TimelineRecommendationResponse> Timeline,
    string OverallExplanation,
    string ModelVersion,
    DateTimeOffset CompletedAt);

public sealed record RecommendationAcceptedResponse(
    Guid RunId,
    string Status,
    string StatusUrl,
    DateTimeOffset RequestedAt);

public sealed record RecommendationRunResponse(
    Guid RunId,
    string Status,
    DateOnly TripDate,
    int AttemptCount,
    DateTimeOffset RequestedAt,
    DateTimeOffset? CompletedAt,
    string? FailureCode,
    RecommendationResponse? Result);

public sealed record RegionRecommendationResponse(Guid NeighborhoodId, string Name, double Score, string Explanation);
public sealed record PlaceRecommendationResponse(int Order, Guid PlaceId, string Name, double Score, string Explanation);
public sealed record TimelineRecommendationResponse(
    int Sequence,
    Guid PlaceId,
    string PlaceName,
    TimeOnly StartTime,
    int DurationMinutes,
    string Explanation);

public sealed record TasteProfileSnapshot(
    IReadOnlyList<Guid> PreferredCategoryIds,
    IReadOnlyList<Guid> PreferredTagIds,
    IReadOnlyList<string> DietaryPreferences,
    string BudgetLevel,
    string TravelPace);

public sealed record GeoPointInput(double Longitude, double Latitude);

public sealed record AiRecommendationRequest(
    Guid RequestId,
    string CorrelationId,
    Guid UserId,
    DateOnly TripDate,
    int AvailableMinutes,
    GeoPointInput? StartLocation,
    TasteProfileSnapshot TasteProfile);

public sealed class AiRecommendationResult
{
    public required string ModelVersion { get; init; }
    public required AiRegionRecommendation Region { get; init; }
    public IReadOnlyList<AiPlaceRecommendation> Places { get; init; } = [];
    public IReadOnlyList<AiTimelineRecommendation> Timeline { get; init; } = [];
    public required string OverallExplanation { get; init; }
}

public sealed record AiRegionRecommendation(Guid NeighborhoodId, string Name, double Score, string Explanation);
public sealed record AiPlaceRecommendation(Guid PlaceId, string Name, double Score, string Explanation);
public sealed record AiTimelineRecommendation(
    int Sequence,
    Guid PlaceId,
    string PlaceName,
    TimeOnly StartTime,
    int DurationMinutes,
    string Explanation);

public interface IRecommendationService
{
    Task<AiRecommendationResult> GenerateAsync(AiRecommendationRequest request, CancellationToken cancellationToken = default);
}

public interface ITasteProfileProvider
{
    Task<TasteProfileSnapshot> GetAsync(Guid userId, CancellationToken cancellationToken = default);
}

public interface IRecommendationRepository
{
    Task AddAsync(RecommendationRun run, CancellationToken cancellationToken = default);
    Task<RecommendationRun?> GetAsync(Guid runId, CancellationToken cancellationToken = default);
    Task<RecommendationRun?> GetLatestAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<RecommendationRun?> ClaimNextAsync(DateTimeOffset now, TimeSpan leaseTimeout, CancellationToken cancellationToken = default);
    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}

public interface IRecommendationOrchestrator
{
    Task<RecommendationAcceptedResponse> EnqueueAsync(Guid userId, GenerateRecommendationRequest request, string correlationId, CancellationToken cancellationToken = default);
    Task<RecommendationRunResponse> GetAsync(Guid userId, Guid runId, CancellationToken cancellationToken = default);
    Task<RecommendationResponse> GetLatestAsync(Guid userId, CancellationToken cancellationToken = default);
}
