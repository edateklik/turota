namespace Rota.Modules.Recommendation.Domain.Entities;

public enum RecommendationRunStatus
{
    Pending = 0,
    Completed = 1,
    Failed = 2
}

public sealed class RecommendationRun
{
    private readonly List<RecommendedPlace> _places = [];
    private readonly List<RecommendationTimelineItem> _timeline = [];

    private RecommendationRun() { }

    private RecommendationRun(Guid id, Guid userId, DateOnly tripDate, string correlationId, DateTimeOffset requestedAt)
    {
        Id = id;
        UserId = userId;
        TripDate = tripDate;
        CorrelationId = correlationId;
        RequestedAt = requestedAt;
        Status = RecommendationRunStatus.Pending;
    }

    public Guid Id { get; private set; }
    public Guid UserId { get; private set; }
    public DateOnly TripDate { get; private set; }
    public string CorrelationId { get; private set; } = null!;
    public RecommendationRunStatus Status { get; private set; }
    public DateTimeOffset RequestedAt { get; private set; }
    public DateTimeOffset? CompletedAt { get; private set; }
    public string? ModelVersion { get; private set; }
    public Guid? NeighborhoodId { get; private set; }
    public string? RegionName { get; private set; }
    public double? RegionScore { get; private set; }
    public string? RegionExplanation { get; private set; }
    public string? OverallExplanation { get; private set; }
    public string? FailureCode { get; private set; }
    public IReadOnlyCollection<RecommendedPlace> Places => _places;
    public IReadOnlyCollection<RecommendationTimelineItem> Timeline => _timeline;

    public static RecommendationRun CreatePending(
        Guid id,
        Guid userId,
        DateOnly tripDate,
        string correlationId,
        DateTimeOffset requestedAt) =>
        new(id, userId, tripDate, correlationId, requestedAt);

    public void Complete(
        string modelVersion,
        Guid neighborhoodId,
        string regionName,
        double regionScore,
        string regionExplanation,
        string overallExplanation,
        IEnumerable<RecommendedPlace> places,
        IEnumerable<RecommendationTimelineItem> timeline,
        DateTimeOffset completedAt)
    {
        if (Status != RecommendationRunStatus.Pending)
            throw new InvalidOperationException("Yalnızca bekleyen öneri çalışması tamamlanabilir.");

        ModelVersion = modelVersion;
        NeighborhoodId = neighborhoodId;
        RegionName = regionName;
        RegionScore = regionScore;
        RegionExplanation = regionExplanation;
        OverallExplanation = overallExplanation;
        _places.AddRange(places);
        _timeline.AddRange(timeline);
        CompletedAt = completedAt;
        Status = RecommendationRunStatus.Completed;
    }

    public void Fail(string failureCode, DateTimeOffset completedAt)
    {
        if (Status != RecommendationRunStatus.Pending) return;
        FailureCode = failureCode;
        CompletedAt = completedAt;
        Status = RecommendationRunStatus.Failed;
    }
}

public sealed class RecommendedPlace
{
    private RecommendedPlace() { }

    public RecommendedPlace(Guid runId, int order, Guid placeId, string name, double score, string explanation)
    {
        RunId = runId;
        Order = order;
        PlaceId = placeId;
        Name = name;
        Score = score;
        Explanation = explanation;
    }

    public Guid RunId { get; private set; }
    public int Order { get; private set; }
    public Guid PlaceId { get; private set; }
    public string Name { get; private set; } = null!;
    public double Score { get; private set; }
    public string Explanation { get; private set; } = null!;
    public RecommendationRun Run { get; private set; } = null!;
}

public sealed class RecommendationTimelineItem
{
    private RecommendationTimelineItem() { }

    public RecommendationTimelineItem(
        Guid runId,
        int sequence,
        Guid placeId,
        string placeName,
        TimeOnly startTime,
        int durationMinutes,
        string explanation)
    {
        RunId = runId;
        Sequence = sequence;
        PlaceId = placeId;
        PlaceName = placeName;
        StartTime = startTime;
        DurationMinutes = durationMinutes;
        Explanation = explanation;
    }

    public Guid RunId { get; private set; }
    public int Sequence { get; private set; }
    public Guid PlaceId { get; private set; }
    public string PlaceName { get; private set; } = null!;
    public TimeOnly StartTime { get; private set; }
    public int DurationMinutes { get; private set; }
    public string Explanation { get; private set; } = null!;
    public RecommendationRun Run { get; private set; } = null!;
}
