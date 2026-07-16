using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rota.Modules.Trip.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class InitialTrip : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "trip");

            migrationBuilder.CreateTable(
                name: "trips",
                schema: "trip",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    source_recommendation_run_id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    trip_date = table.Column<DateOnly>(type: "date", nullable: false),
                    available_minutes = table.Column<int>(type: "integer", nullable: false),
                    neighborhood_id = table.Column<Guid>(type: "uuid", nullable: false),
                    region_name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    overall_explanation = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: false),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_trips", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "trip_stops",
                schema: "trip",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    trip_id = table.Column<Guid>(type: "uuid", nullable: false),
                    sequence = table.Column<int>(type: "integer", nullable: false),
                    place_id = table.Column<Guid>(type: "uuid", nullable: false),
                    place_name = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    start_time = table.Column<TimeOnly>(type: "time without time zone", nullable: false),
                    duration_minutes = table.Column<int>(type: "integer", nullable: false),
                    explanation = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    longitude = table.Column<double>(type: "double precision", nullable: false),
                    latitude = table.Column<double>(type: "double precision", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_trip_stops", x => x.id);
                    table.ForeignKey(
                        name: "FK_trip_stops_trips_trip_id",
                        column: x => x.trip_id,
                        principalSchema: "trip",
                        principalTable: "trips",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_trip_stops_trip_id_sequence",
                schema: "trip",
                table: "trip_stops",
                columns: new[] { "trip_id", "sequence" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_trips_source_recommendation_run_id",
                schema: "trip",
                table: "trips",
                column: "source_recommendation_run_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_trips_user_id_trip_date",
                schema: "trip",
                table: "trips",
                columns: new[] { "user_id", "trip_date" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "trip_stops",
                schema: "trip");

            migrationBuilder.DropTable(
                name: "trips",
                schema: "trip");
        }
    }
}
