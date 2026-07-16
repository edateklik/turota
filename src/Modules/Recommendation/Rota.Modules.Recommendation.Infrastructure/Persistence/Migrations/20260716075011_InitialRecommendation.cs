using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rota.Modules.Recommendation.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class InitialRecommendation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "recommendation");

            migrationBuilder.CreateTable(
                name: "recommendation_runs",
                schema: "recommendation",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    trip_date = table.Column<DateOnly>(type: "date", nullable: false),
                    correlation_id = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    requested_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    completed_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    model_version = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    neighborhood_id = table.Column<Guid>(type: "uuid", nullable: true),
                    region_name = table.Column<string>(type: "character varying(180)", maxLength: 180, nullable: true),
                    region_score = table.Column<double>(type: "double precision", nullable: true),
                    region_explanation = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    overall_explanation = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: true),
                    failure_code = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_recommendation_runs", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "recommended_places",
                schema: "recommendation",
                columns: table => new
                {
                    run_id = table.Column<Guid>(type: "uuid", nullable: false),
                    order = table.Column<int>(type: "integer", nullable: false),
                    place_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "character varying(180)", maxLength: 180, nullable: false),
                    score = table.Column<double>(type: "double precision", nullable: false),
                    explanation = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_recommended_places", x => new { x.run_id, x.order });
                    table.ForeignKey(
                        name: "FK_recommended_places_recommendation_runs_run_id",
                        column: x => x.run_id,
                        principalSchema: "recommendation",
                        principalTable: "recommendation_runs",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "timeline_items",
                schema: "recommendation",
                columns: table => new
                {
                    run_id = table.Column<Guid>(type: "uuid", nullable: false),
                    sequence = table.Column<int>(type: "integer", nullable: false),
                    place_id = table.Column<Guid>(type: "uuid", nullable: false),
                    place_name = table.Column<string>(type: "character varying(180)", maxLength: 180, nullable: false),
                    start_time = table.Column<TimeOnly>(type: "time without time zone", nullable: false),
                    duration_minutes = table.Column<int>(type: "integer", nullable: false),
                    explanation = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_timeline_items", x => new { x.run_id, x.sequence });
                    table.ForeignKey(
                        name: "FK_timeline_items_recommendation_runs_run_id",
                        column: x => x.run_id,
                        principalSchema: "recommendation",
                        principalTable: "recommendation_runs",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "ix_recommendation_runs_correlation_id",
                schema: "recommendation",
                table: "recommendation_runs",
                column: "correlation_id");

            migrationBuilder.CreateIndex(
                name: "ix_recommendation_runs_user_requested_at",
                schema: "recommendation",
                table: "recommendation_runs",
                columns: new[] { "user_id", "requested_at" },
                descending: new[] { false, true });

            migrationBuilder.CreateIndex(
                name: "IX_recommended_places_place_id",
                schema: "recommendation",
                table: "recommended_places",
                column: "place_id");

            migrationBuilder.CreateIndex(
                name: "IX_timeline_items_place_id",
                schema: "recommendation",
                table: "timeline_items",
                column: "place_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "recommended_places",
                schema: "recommendation");

            migrationBuilder.DropTable(
                name: "timeline_items",
                schema: "recommendation");

            migrationBuilder.DropTable(
                name: "recommendation_runs",
                schema: "recommendation");
        }
    }
}
