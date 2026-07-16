using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Rota.Modules.Discovery.Infrastructure.Persistence;

public sealed class DiscoveryDbContextFactory : IDesignTimeDbContextFactory<DiscoveryDbContext>
{
    public DiscoveryDbContext CreateDbContext(string[] args)
    {
        var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__DiscoveryDb")
            ?? "Host=localhost;Port=5432;Database=rota;Username=rota;Password=rota_dev_password";

        var options = new DbContextOptionsBuilder<DiscoveryDbContext>()
            .UseNpgsql(connectionString, npgsql =>
            {
                npgsql.UseNetTopologySuite();
                npgsql.MigrationsHistoryTable("__ef_migrations_history", "discovery");
            })
            .Options;

        return new DiscoveryDbContext(options);
    }
}
