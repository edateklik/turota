using Rota.Modules.Recommendation.Domain.Entities;
using Xunit;

namespace Rota.Modules.Recommendation.UnitTests;

public sealed class RecommendationRunTests
{
    [Fact]
    public void Complete_ProcessingRun_StoresResultAndTransitionsToCompleted()
    {
        var runId = Guid.NewGuid();
        var placeId = Guid.NewGuid();
        var neighborhoodId = Guid.NewGuid();
        var completedAt = DateTimeOffset.UtcNow;
        var run = RecommendationRun.CreatePending(
            runId,
            Guid.NewGuid(),
            new DateOnly(2026, 7, 17),
            "correlation-1",
            new RecommendationRequestData(480, null, null, "{}"),
            completedAt.AddSeconds(-1));
        run.StartProcessing(completedAt.AddMilliseconds(-500));

        run.Complete(
            "model-v1",
            neighborhoodId,
            "Caferağa",
            0.94,
            "Bölge açıklaması",
            "Genel açıklama",
            [new RecommendedPlace(runId, 1, placeId, "Mekan", 0.91, "Mekan açıklaması")],
            [new RecommendationTimelineItem(runId, 1, placeId, "Mekan", new TimeOnly(9, 0), 60, "Rota açıklaması")],
            completedAt);

        Assert.Equal(RecommendationRunStatus.Completed, run.Status);
        Assert.Equal(completedAt, run.CompletedAt);
        Assert.Equal(neighborhoodId, run.NeighborhoodId);
        Assert.Single(run.Places);
        Assert.Single(run.Timeline);
    }

    [Fact]
    public void Complete_CompletedRun_Throws()
    {
        var runId = Guid.NewGuid();
        var run = RecommendationRun.CreatePending(
            runId,
            Guid.NewGuid(),
            new DateOnly(2026, 7, 17),
            "correlation-2",
            new RecommendationRequestData(480, null, null, "{}"),
            DateTimeOffset.UtcNow);
        var complete = () => run.Complete(
            "model-v1", Guid.NewGuid(), "Moda", 0.9, "Açıklama", "Genel", [], [], DateTimeOffset.UtcNow);

        run.StartProcessing(DateTimeOffset.UtcNow);
        complete();

        Assert.Throws<InvalidOperationException>(complete);
    }

    [Fact]
    public void Fail_ProcessingRun_StoresFailureAndTransitionsToFailed()
    {
        var failedAt = DateTimeOffset.UtcNow;
        var run = RecommendationRun.CreatePending(
            Guid.NewGuid(),
            Guid.NewGuid(),
            new DateOnly(2026, 7, 17),
            "correlation-3",
            new RecommendationRequestData(480, null, null, "{}"),
            failedAt.AddSeconds(-1));
        run.StartProcessing(failedAt.AddMilliseconds(-500));

        run.Fail("AI_SERVICE_UNAVAILABLE", failedAt);

        Assert.Equal(RecommendationRunStatus.Failed, run.Status);
        Assert.Equal("AI_SERVICE_UNAVAILABLE", run.FailureCode);
        Assert.Equal(failedAt, run.CompletedAt);
    }

    [Fact]
    public void ScheduleRetry_ProcessingRun_ReturnsToPendingAndKeepsAttemptCount()
    {
        var run = RecommendationRun.CreatePending(
            Guid.NewGuid(),
            Guid.NewGuid(),
            new DateOnly(2026, 7, 17),
            "correlation-4",
            new RecommendationRequestData(480, null, null, "{}"),
            DateTimeOffset.UtcNow);
        run.StartProcessing(DateTimeOffset.UtcNow);
        var retryAt = DateTimeOffset.UtcNow.AddSeconds(1);

        run.ScheduleRetry("AI_SERVICE_TIMEOUT", retryAt);

        Assert.Equal(RecommendationRunStatus.Pending, run.Status);
        Assert.Equal(1, run.AttemptCount);
        Assert.Equal(retryAt, run.NextAttemptAt);
        Assert.Equal("AI_SERVICE_TIMEOUT", run.FailureCode);
    }
}
