using Microsoft.EntityFrameworkCore;
using Rota.Modules.Recommendation.Domain.Entities;
using Rota.Modules.Recommendation.Infrastructure.Outbox;

namespace Rota.Modules.Recommendation.Infrastructure.Persistence;

public sealed class RecommendationDbContext(DbContextOptions<RecommendationDbContext> options) : DbContext(options)
{
    public DbSet<RecommendationRun> RecommendationRuns => Set<RecommendationRun>();
    public DbSet<RecommendedPlace> RecommendedPlaces => Set<RecommendedPlace>();
    public DbSet<RecommendationTimelineItem> TimelineItems => Set<RecommendationTimelineItem>();
    public DbSet<RecommendationOutboxMessage> OutboxMessages => Set<RecommendationOutboxMessage>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("recommendation");

        modelBuilder.Entity<RecommendationRun>(builder =>
        {
            builder.ToTable("recommendation_runs");
            builder.HasKey(x => x.Id);
            builder.Property(x => x.Id).HasColumnName("id").ValueGeneratedNever();
            builder.Property(x => x.UserId).HasColumnName("user_id");
            builder.Property(x => x.TripDate).HasColumnName("trip_date");
            builder.Property(x => x.CorrelationId).HasColumnName("correlation_id").HasMaxLength(100).IsRequired();
            builder.Property(x => x.Status).HasColumnName("status").HasConversion<string>().HasMaxLength(20).IsRequired();
            builder.Property(x => x.RequestedAt).HasColumnName("requested_at");
            builder.Property(x => x.AvailableMinutes).HasColumnName("available_minutes");
            builder.Property(x => x.StartLongitude).HasColumnName("start_longitude");
            builder.Property(x => x.StartLatitude).HasColumnName("start_latitude");
            builder.Property(x => x.TasteProfileJson).HasColumnName("taste_profile_json").HasColumnType("jsonb").IsRequired();
            builder.Property(x => x.AttemptCount).HasColumnName("attempt_count");
            builder.Property(x => x.ProcessingStartedAt).HasColumnName("processing_started_at");
            builder.Property(x => x.NextAttemptAt).HasColumnName("next_attempt_at");
            builder.Property(x => x.CompletedAt).HasColumnName("completed_at");
            builder.Property(x => x.ModelVersion).HasColumnName("model_version").HasMaxLength(80);
            builder.Property(x => x.NeighborhoodId).HasColumnName("neighborhood_id");
            builder.Property(x => x.RegionName).HasColumnName("region_name").HasMaxLength(180);
            builder.Property(x => x.RegionScore).HasColumnName("region_score");
            builder.Property(x => x.RegionExplanation).HasColumnName("region_explanation").HasMaxLength(2_000);
            builder.Property(x => x.OverallExplanation).HasColumnName("overall_explanation").HasMaxLength(4_000);
            builder.Property(x => x.FailureCode).HasColumnName("failure_code").HasMaxLength(80);
            builder.HasIndex(x => new { x.UserId, x.RequestedAt }).IsDescending(false, true)
                .HasDatabaseName("ix_recommendation_runs_user_requested_at");
            builder.HasIndex(x => x.CorrelationId).HasDatabaseName("ix_recommendation_runs_correlation_id");
            builder.HasIndex(x => new { x.Status, x.NextAttemptAt, x.RequestedAt })
                .HasDatabaseName("ix_recommendation_runs_job_queue");
            builder.HasIndex(x => new { x.Status, x.ProcessingStartedAt })
                .HasDatabaseName("ix_recommendation_runs_processing_lease");
            builder.Navigation(x => x.Places).UsePropertyAccessMode(PropertyAccessMode.Field);
            builder.Navigation(x => x.Timeline).UsePropertyAccessMode(PropertyAccessMode.Field);
        });

        modelBuilder.Entity<RecommendedPlace>(builder =>
        {
            builder.ToTable("recommended_places");
            builder.HasKey(x => new { x.RunId, x.Order });
            builder.Property(x => x.RunId).HasColumnName("run_id");
            builder.Property(x => x.Order).HasColumnName("order");
            builder.Property(x => x.PlaceId).HasColumnName("place_id");
            builder.Property(x => x.Name).HasColumnName("name").HasMaxLength(180).IsRequired();
            builder.Property(x => x.Score).HasColumnName("score");
            builder.Property(x => x.Explanation).HasColumnName("explanation").HasMaxLength(2_000).IsRequired();
            builder.HasOne(x => x.Run).WithMany(x => x.Places).HasForeignKey(x => x.RunId).OnDelete(DeleteBehavior.Cascade);
            builder.HasIndex(x => x.PlaceId);
        });

        modelBuilder.Entity<RecommendationTimelineItem>(builder =>
        {
            builder.ToTable("timeline_items");
            builder.HasKey(x => new { x.RunId, x.Sequence });
            builder.Property(x => x.RunId).HasColumnName("run_id");
            builder.Property(x => x.Sequence).HasColumnName("sequence");
            builder.Property(x => x.PlaceId).HasColumnName("place_id");
            builder.Property(x => x.PlaceName).HasColumnName("place_name").HasMaxLength(180).IsRequired();
            builder.Property(x => x.StartTime).HasColumnName("start_time");
            builder.Property(x => x.DurationMinutes).HasColumnName("duration_minutes");
            builder.Property(x => x.Explanation).HasColumnName("explanation").HasMaxLength(2_000).IsRequired();
            builder.HasOne(x => x.Run).WithMany(x => x.Timeline).HasForeignKey(x => x.RunId).OnDelete(DeleteBehavior.Cascade);
            builder.HasIndex(x => x.PlaceId);
        });

        modelBuilder.Entity<RecommendationOutboxMessage>(builder =>
        {
            builder.ToTable("outbox_messages");
            builder.HasKey(x => x.Id);
            builder.Property(x => x.Id).HasColumnName("id").ValueGeneratedNever();
            builder.Property(x => x.AggregateId).HasColumnName("aggregate_id");
            builder.Property(x => x.Type).HasColumnName("type").HasMaxLength(100).IsRequired();
            builder.Property(x => x.Payload).HasColumnName("payload").HasColumnType("jsonb").IsRequired();
            builder.Property(x => x.Status).HasColumnName("status").HasConversion<string>().HasMaxLength(20).IsRequired();
            builder.Property(x => x.OccurredAt).HasColumnName("occurred_at");
            builder.Property(x => x.AttemptCount).HasColumnName("attempt_count");
            builder.Property(x => x.ProcessingStartedAt).HasColumnName("processing_started_at");
            builder.Property(x => x.NextAttemptAt).HasColumnName("next_attempt_at");
            builder.Property(x => x.ProcessedAt).HasColumnName("processed_at");
            builder.Property(x => x.LastError).HasColumnName("last_error").HasMaxLength(2_000);
            builder.HasIndex(x => new { x.Status, x.NextAttemptAt, x.OccurredAt })
                .HasDatabaseName("ix_outbox_messages_dispatch_queue");
            builder.HasIndex(x => new { x.Status, x.ProcessingStartedAt })
                .HasDatabaseName("ix_outbox_messages_processing_lease");
            builder.HasIndex(x => new { x.AggregateId, x.Type })
                .IsUnique()
                .HasDatabaseName("ux_outbox_messages_aggregate_type");
        });
    }
}
