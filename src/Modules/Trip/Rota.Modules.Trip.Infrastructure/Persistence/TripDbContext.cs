using Microsoft.EntityFrameworkCore;
using Rota.Modules.Trip.Domain.Entities;

namespace Rota.Modules.Trip.Infrastructure.Persistence;

public sealed class TripDbContext(DbContextOptions<TripDbContext> options) : DbContext(options)
{
    public DbSet<Domain.Entities.Trip> Trips => Set<Domain.Entities.Trip>();
    public DbSet<TripStop> Stops => Set<TripStop>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("trip");
        modelBuilder.Entity<Domain.Entities.Trip>(builder =>
        {
            builder.ToTable("trips");
            builder.HasKey(x => x.Id);
            builder.Property(x => x.Id).HasColumnName("id");
            builder.Property(x => x.SourceRecommendationRunId).HasColumnName("source_recommendation_run_id");
            builder.Property(x => x.UserId).HasColumnName("user_id");
            builder.Property(x => x.TripDate).HasColumnName("trip_date");
            builder.Property(x => x.AvailableMinutes).HasColumnName("available_minutes");
            builder.Property(x => x.NeighborhoodId).HasColumnName("neighborhood_id");
            builder.Property(x => x.RegionName).HasColumnName("region_name").HasMaxLength(200);
            builder.Property(x => x.OverallExplanation).HasColumnName("overall_explanation").HasMaxLength(4000);
            builder.Property(x => x.Status).HasColumnName("status").HasConversion<string>().HasMaxLength(20);
            builder.Property(x => x.CreatedAt).HasColumnName("created_at");
            builder.Property(x => x.UpdatedAt).HasColumnName("updated_at").IsConcurrencyToken();
            builder.HasIndex(x => x.SourceRecommendationRunId).IsUnique();
            builder.HasIndex(x => new { x.UserId, x.TripDate });
            builder.HasMany(x => x.Stops).WithOne(x => x.Trip).HasForeignKey(x => x.TripId).OnDelete(DeleteBehavior.Cascade);
            builder.Navigation(x => x.Stops).UsePropertyAccessMode(PropertyAccessMode.Field);
        });

        modelBuilder.Entity<TripStop>(builder =>
        {
            builder.ToTable("trip_stops");
            builder.HasKey(x => x.Id);
            builder.Property(x => x.Id).HasColumnName("id");
            builder.Property(x => x.TripId).HasColumnName("trip_id");
            builder.Property(x => x.Sequence).HasColumnName("sequence");
            builder.Property(x => x.PlaceId).HasColumnName("place_id");
            builder.Property(x => x.PlaceName).HasColumnName("place_name").HasMaxLength(300);
            builder.Property(x => x.StartTime).HasColumnName("start_time");
            builder.Property(x => x.DurationMinutes).HasColumnName("duration_minutes");
            builder.Property(x => x.Explanation).HasColumnName("explanation").HasMaxLength(2000);
            builder.Property(x => x.Longitude).HasColumnName("longitude");
            builder.Property(x => x.Latitude).HasColumnName("latitude");
            builder.HasIndex(x => new { x.TripId, x.Sequence }).IsUnique();
        });
    }
}
