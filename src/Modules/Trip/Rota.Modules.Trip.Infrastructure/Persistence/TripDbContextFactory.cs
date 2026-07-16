using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Rota.Modules.Trip.Infrastructure.Persistence;

public sealed class TripDbContextFactory : IDesignTimeDbContextFactory<TripDbContext>
{
    public TripDbContext CreateDbContext(string[] args)
    {
        var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__TripDb")
            ?? "Host=localhost;Port=5432;Database=rota;Username=rota;Password=rota_dev_password";
        var builder = new DbContextOptionsBuilder<TripDbContext>();
        builder.UseNpgsql(connectionString, npgsql =>
            npgsql.MigrationsHistoryTable("__ef_migrations_history", "trip"));
        return new TripDbContext(builder.Options);
    }
}
