namespace Rota.Modules.Recommendation.Domain.Entities;

public enum RecommendationRunStatus
{
    Pending = 0,
    Processing = 1,
    Completed = 2,
    Failed = 3
}

public sealed record RecommendationRequestData(
    int AvailableMinutes,
    double? StartLongitude,
    double? StartLatitude,
    string TasteProfileJson);

public sealed class RecommendationRun
{
    private readonly List<RecommendedPlace> _places = [];
    private readonly List<RecommendationTimelineItem> _timeline = [];

    private RecommendationRun() { }

    private RecommendationRun(
        Guid id,
        Guid userId,
        DateOnly tripDate,
        string correlationId,
        RecommendationRequestData request,
        DateTimeOffset requestedAt)
    {
        Id = id;
        UserId = userId;
        TripDate = tripDate;
        CorrelationId = correlationId;
        AvailableMinutes = request.AvailableMinutes;
        StartLongitude = request.StartLongitude;
        StartLatitude = request.StartLatitude;
        TasteProfileJson = request.TasteProfileJson;
        RequestedAt = requestedAt;
        Status = RecommendationRunStatus.Pending;
    }

    public Guid Id { get; private set; }
    public Guid UserId { get; private set; }
    public DateOnly TripDate { get; private set; }
    public string CorrelationId { get; private set; } = null!;
    public RecommendationRunStatus Status { get; private set; }
    public DateTimeOffset RequestedAt { get; private set; }
    public int AvailableMinutes { get; private set; }
    public double? StartLongitude { get; private set; }
    public double? StartLatitude { get; private set; }
    public string TasteProfileJson { get; private set; } = null!;
    public int AttemptCount { get; private set; }
    public DateTimeOffset? ProcessingStartedAt { get; private set; }
    public DateTimeOffset? NextAttemptAt { get; private set; }
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
        RecommendationRequestData request,
        DateTimeOffset requestedAt) =>
        new(id, userId, tripDate, correlationId, request, requestedAt);

    public void StartProcessing(DateTimeOffset startedAt)
    {
        if (Status is not (RecommendationRunStatus.Pending or RecommendationRunStatus.Processing))
            throw new InvalidOperationException("Yalnızca bekleyen veya lease süresi dolmuş öneri çalışması işlenebilir.");

        Status = RecommendationRunStatus.Processing;
        ProcessingStartedAt = startedAt;
        NextAttemptAt = null;
        FailureCode = null;
        AttemptCount++;
    }

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
        if (Status != RecommendationRunStatus.Processing)
            throw new InvalidOperationException("Yalnızca işlenmekte olan öneri çalışması tamamlanabilir.");

        ModelVersion = modelVersion;
        NeighborhoodId = neighborhoodId;
        RegionName = regionName;
        RegionScore = regionScore;
        RegionExplanation = regionExplanation;
        OverallExplanation = overallExplanation;
        _places.AddRange(places);
        _timeline.AddRange(timeline);
        CompletedAt = completedAt;
        ProcessingStartedAt = null;
        Status = RecommendationRunStatus.Completed;
    }

    public void Fail(string failureCode, DateTimeOffset completedAt)
    {
        if (Status != RecommendationRunStatus.Processing)
            throw new InvalidOperationException("Yalnızca işlenmekte olan öneri çalışması başarısız olabilir.");
        FailureCode = failureCode;
        CompletedAt = completedAt;
        ProcessingStartedAt = null;
        Status = RecommendationRunStatus.Failed;
    }

    public void ScheduleRetry(string failureCode, DateTimeOffset nextAttemptAt)
    {
        if (Status != RecommendationRunStatus.Processing)
            throw new InvalidOperationException("Yalnızca işlenmekte olan öneri çalışması yeniden denenebilir.");
        FailureCode = failureCode;
        ProcessingStartedAt = null;
        NextAttemptAt = nextAttemptAt;
        Status = RecommendationRunStatus.Pending;
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
