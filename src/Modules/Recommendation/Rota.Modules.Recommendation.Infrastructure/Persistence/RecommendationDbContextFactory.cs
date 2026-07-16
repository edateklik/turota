using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Rota.Modules.Recommendation.Infrastructure.Persistence;

public sealed class RecommendationDbContextFactory : IDesignTimeDbContextFactory<RecommendationDbContext>
{
    public RecommendationDbContext CreateDbContext(string[] args)
    {
        var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__RecommendationDb")
            ?? "Host=localhost;Port=5432;Database=rota;Username=rota;Password=rota_dev_password";
        var options = new DbContextOptionsBuilder<RecommendationDbContext>()
            .UseNpgsql(connectionString, npgsql => npgsql.MigrationsHistoryTable("__ef_migrations_history", "recommendation"))
            .Options;
        return new RecommendationDbContext(options);
    }
}
