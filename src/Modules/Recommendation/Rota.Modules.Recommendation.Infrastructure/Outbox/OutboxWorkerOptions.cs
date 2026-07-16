namespace Rota.Modules.Recommendation.Infrastructure.Outbox;

public sealed class OutboxWorkerOptions
{
    public const string SectionName = "OutboxWorker";
    public int PollIntervalMilliseconds { get; init; } = 250;
    public int LeaseSeconds { get; init; } = 30;
    public int MaxAttempts { get; init; } = 10;
    public int RetryDelayMilliseconds { get; init; } = 500;
    public int ProcessedRetentionHours { get; init; } = 168;
    public int CleanupIntervalMinutes { get; init; } = 60;
}
