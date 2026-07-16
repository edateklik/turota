using Microsoft.EntityFrameworkCore;
using Rota.Modules.Discovery.Domain.Entities;
using Rota.Modules.Discovery.Infrastructure.Persistence.Seeding;

namespace Rota.Modules.Discovery.Infrastructure.Persistence;

public sealed class DiscoveryDbContext(DbContextOptions<DiscoveryDbContext> options) : DbContext(options)
{
    public DbSet<City> Cities => Set<City>();
    public DbSet<Neighborhood> Neighborhoods => Set<Neighborhood>();
    public DbSet<Place> Places => Set<Place>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Tag> Tags => Set<Tag>();
    public DbSet<PlaceFeatureVector> PlaceFeatureVectors => Set<PlaceFeatureVector>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("discovery");
        modelBuilder.HasPostgresExtension("postgis");
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(DiscoveryDbContext).Assembly);
        DiscoverySeed.Apply(modelBuilder);
    }
}
