namespace Rota.Modules.Recommendation.Infrastructure.Workers;

public sealed class RecommendationWorkerOptions
{
    public const string SectionName = "RecommendationWorker";
    public int PollIntervalMilliseconds { get; init; } = 250;
    public int LeaseSeconds { get; init; } = 30;
    public int MaxAttempts { get; init; } = 3;
    public int RetryDelayMilliseconds { get; init; } = 500;
}
