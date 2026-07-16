using System.Data;
using Microsoft.EntityFrameworkCore;
using Rota.Modules.Recommendation.Infrastructure.Persistence;

namespace Rota.Modules.Recommendation.Infrastructure.Outbox;

public sealed class RecommendationOutboxStore(RecommendationDbContext dbContext)
{
    public async Task<RecommendationOutboxMessage?> ClaimNextAsync(
        DateTimeOffset now,
        TimeSpan leaseTimeout,
        CancellationToken cancellationToken)
    {
        var leaseCutoff = now.Subtract(leaseTimeout);
        var strategy = dbContext.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var transaction = await dbContext.Database.BeginTransactionAsync(
                IsolationLevel.ReadCommitted,
                cancellationToken);
            var message = await dbContext.OutboxMessages
                .FromSqlInterpolated($"""
                    SELECT *
                    FROM recommendation.outbox_messages
                    WHERE (status = 'Pending' AND (next_attempt_at IS NULL OR next_attempt_at <= {now}))
                       OR (status = 'Processing' AND processing_started_at < {leaseCutoff})
                    ORDER BY occurred_at
                    FOR UPDATE SKIP LOCKED
                    LIMIT 1
                    """)
                .SingleOrDefaultAsync(cancellationToken);
            if (message is null)
            {
                await transaction.RollbackAsync(cancellationToken);
                return null;
            }

            message.StartProcessing(now);
            await dbContext.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return message;
        });
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken) =>
        dbContext.SaveChangesAsync(cancellationToken);

    public Task<int> DeleteProcessedBeforeAsync(
        DateTimeOffset cutoff,
        CancellationToken cancellationToken) =>
        dbContext.OutboxMessages
            .Where(message => message.Status == OutboxMessageStatus.Processed && message.ProcessedAt < cutoff)
            .ExecuteDeleteAsync(cancellationToken);
}
