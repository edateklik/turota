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

    public async Task SaveChangesAsync(CancellationToken cancellationToken = default) =>
        await dbContext.SaveChangesAsync(cancellationToken);
}
