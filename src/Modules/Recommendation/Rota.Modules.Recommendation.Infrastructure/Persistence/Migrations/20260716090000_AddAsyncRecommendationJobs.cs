using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rota.Modules.Recommendation.Infrastructure.Persistence.Migrations;

[DbContext(typeof(RecommendationDbContext))]
[Migration("20260716090000_AddAsyncRecommendationJobs")]
public sealed class AddAsyncRecommendationJobs : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<int>(
            name: "attempt_count",
            schema: "recommendation",
            table: "recommendation_runs",
            type: "integer",
            nullable: false,
            defaultValue: 0);
        migrationBuilder.AddColumn<int>(
            name: "available_minutes",
            schema: "recommendation",
            table: "recommendation_runs",
            type: "integer",
            nullable: false,
            defaultValue: 480);
        migrationBuilder.AddColumn<DateTimeOffset>(
            name: "next_attempt_at",
            schema: "recommendation",
            table: "recommendation_runs",
            type: "timestamp with time zone",
            nullable: true);
        migrationBuilder.AddColumn<DateTimeOffset>(
            name: "processing_started_at",
            schema: "recommendation",
            table: "recommendation_runs",
            type: "timestamp with time zone",
            nullable: true);
        migrationBuilder.AddColumn<double>(
            name: "start_latitude",
            schema: "recommendation",
            table: "recommendation_runs",
            type: "double precision",
            nullable: true);
        migrationBuilder.AddColumn<double>(
            name: "start_longitude",
            schema: "recommendation",
            table: "recommendation_runs",
            type: "double precision",
            nullable: true);
        migrationBuilder.AddColumn<string>(
            name: "taste_profile_json",
            schema: "recommendation",
            table: "recommendation_runs",
            type: "jsonb",
            nullable: false,
            defaultValue: "{}");

        migrationBuilder.CreateIndex(
            name: "ix_recommendation_runs_job_queue",
            schema: "recommendation",
            table: "recommendation_runs",
            columns: new[] { "status", "next_attempt_at", "requested_at" });
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropIndex(
            name: "ix_recommendation_runs_job_queue",
            schema: "recommendation",
            table: "recommendation_runs");
        migrationBuilder.DropColumn(name: "attempt_count", schema: "recommendation", table: "recommendation_runs");
        migrationBuilder.DropColumn(name: "available_minutes", schema: "recommendation", table: "recommendation_runs");
        migrationBuilder.DropColumn(name: "next_attempt_at", schema: "recommendation", table: "recommendation_runs");
        migrationBuilder.DropColumn(name: "processing_started_at", schema: "recommendation", table: "recommendation_runs");
        migrationBuilder.DropColumn(name: "start_latitude", schema: "recommendation", table: "recommendation_runs");
        migrationBuilder.DropColumn(name: "start_longitude", schema: "recommendation", table: "recommendation_runs");
        migrationBuilder.DropColumn(name: "taste_profile_json", schema: "recommendation", table: "recommendation_runs");
    }
}
