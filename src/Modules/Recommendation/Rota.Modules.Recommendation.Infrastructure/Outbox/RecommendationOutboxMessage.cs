namespace Rota.Modules.Recommendation.Infrastructure.Outbox;

public enum OutboxMessageStatus
{
    Pending = 0,
    Processing = 1,
    Processed = 2,
    Failed = 3
}

public sealed class RecommendationOutboxMessage
{
    private RecommendationOutboxMessage() { }

    private RecommendationOutboxMessage(
        Guid id,
        Guid aggregateId,
        string type,
        string payload,
        DateTimeOffset occurredAt)
    {
        Id = id;
        AggregateId = aggregateId;
        Type = type;
        Payload = payload;
        OccurredAt = occurredAt;
        Status = OutboxMessageStatus.Pending;
    }

    public Guid Id { get; private set; }
    public Guid AggregateId { get; private set; }
    public string Type { get; private set; } = null!;
    public string Payload { get; private set; } = null!;
    public OutboxMessageStatus Status { get; private set; }
    public DateTimeOffset OccurredAt { get; private set; }
    public int AttemptCount { get; private set; }
    public DateTimeOffset? ProcessingStartedAt { get; private set; }
    public DateTimeOffset? NextAttemptAt { get; private set; }
    public DateTimeOffset? ProcessedAt { get; private set; }
    public string? LastError { get; private set; }

    public static RecommendationOutboxMessage Create(
        Guid aggregateId,
        string type,
        string payload,
        DateTimeOffset occurredAt) =>
        new(Guid.NewGuid(), aggregateId, type, payload, occurredAt);

    public void StartProcessing(DateTimeOffset startedAt)
    {
        if (Status is not (OutboxMessageStatus.Pending or OutboxMessageStatus.Processing))
            throw new InvalidOperationException("Yalnızca bekleyen veya lease süresi dolmuş outbox mesajı işlenebilir.");
        Status = OutboxMessageStatus.Processing;
        ProcessingStartedAt = startedAt;
        NextAttemptAt = null;
        AttemptCount++;
    }

    public void MarkProcessed(DateTimeOffset processedAt)
    {
        EnsureProcessing();
        Status = OutboxMessageStatus.Processed;
        ProcessingStartedAt = null;
        ProcessedAt = processedAt;
        LastError = null;
    }

    public void ScheduleRetry(string error, DateTimeOffset nextAttemptAt)
    {
        EnsureProcessing();
        Status = OutboxMessageStatus.Pending;
        ProcessingStartedAt = null;
        NextAttemptAt = nextAttemptAt;
        LastError = Truncate(error);
    }

    public void MarkFailed(string error)
    {
        EnsureProcessing();
        Status = OutboxMessageStatus.Failed;
        ProcessingStartedAt = null;
        LastError = Truncate(error);
    }

    private void EnsureProcessing()
    {
        if (Status != OutboxMessageStatus.Processing)
            throw new InvalidOperationException("Outbox mesajı Processing durumunda olmalıdır.");
    }

    private static string Truncate(string value) =>
        value.Length <= 2_000 ? value : value[..2_000];
}
