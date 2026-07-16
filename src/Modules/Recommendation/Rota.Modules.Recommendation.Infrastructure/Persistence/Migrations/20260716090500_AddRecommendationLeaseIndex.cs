using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rota.Modules.Recommendation.Infrastructure.Persistence.Migrations;

[DbContext(typeof(RecommendationDbContext))]
[Migration("20260716090500_AddRecommendationLeaseIndex")]
public sealed class AddRecommendationLeaseIndex : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder) =>
        migrationBuilder.CreateIndex(
            name: "ix_recommendation_runs_processing_lease",
            schema: "recommendation",
            table: "recommendation_runs",
            columns: new[] { "status", "processing_started_at" });

    protected override void Down(MigrationBuilder migrationBuilder) =>
        migrationBuilder.DropIndex(
            name: "ix_recommendation_runs_processing_lease",
            schema: "recommendation",
            table: "recommendation_runs");
}
