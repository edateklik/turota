using System.Data;
using Microsoft.EntityFrameworkCore;
using Rota.Modules.Recommendation.Application.Contracts;
using Rota.Modules.Recommendation.Domain.Entities;

namespace Rota.Modules.Recommendation.Infrastructure.Persistence;

public sealed class RecommendationRepository(RecommendationDbContext dbContext) : IRecommendationRepository
{
    public async Task AddAsync(RecommendationRun run, CancellationToken cancellationToken = default) =>
        await dbContext.RecommendationRuns.AddAsync(run, cancellationToken);

    public Task<RecommendationRun?> GetAsync(Guid runId, CancellationToken cancellationToken = default) =>
        dbContext.RecommendationRuns.AsNoTracking()
            .AsSplitQuery()
            .Include(x => x.Places)
            .Include(x => x.Timeline)
            .SingleOrDefaultAsync(x => x.Id == runId, cancellationToken);

    public Task<RecommendationRun?> GetLatestAsync(Guid userId, CancellationToken cancellationToken = default) =>
        dbContext.RecommendationRuns.AsNoTracking()
            .AsSplitQuery()
            .Include(x => x.Places)
            .Include(x => x.Timeline)
            .Where(x => x.UserId == userId && x.Status == RecommendationRunStatus.Completed)
            .OrderByDescending(x => x.RequestedAt)
            .FirstOrDefaultAsync(cancellationToken);

    public async Task<RecommendationRun?> ClaimNextAsync(
        DateTimeOffset now,
        TimeSpan leaseTimeout,
        CancellationToken cancellationToken = default)
    {
        var leaseCutoff = now.Subtract(leaseTimeout);
        var strategy = dbContext.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var transaction = await dbContext.Database.BeginTransactionAsync(
                IsolationLevel.ReadCommitted,
                cancellationToken);
            var run = await dbContext.RecommendationRuns
                .FromSqlInterpolated($"""
                    SELECT *
                    FROM recommendation.recommendation_runs
                    WHERE (status = 'Pending' AND (next_attempt_at IS NULL OR next_attempt_at <= {now}))
                       OR (status = 'Processing' AND processing_started_at < {leaseCutoff})
                    ORDER BY requested_at
                    FOR UPDATE SKIP LOCKED
                    LIMIT 1
                    """)
                .SingleOrDefaultAsync(cancellationToken);
            if (run is null)
            {
                await transaction.RollbackAsync(cancellationToken);
                return null;
            }

            run.StartProcessing(now);
            await dbContext.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return run;
        });
    }

    public async Task SaveChangesAsync(CancellationToken cancellationToken = default) =>
        await dbContext.SaveChangesAsync(cancellationToken);
}
