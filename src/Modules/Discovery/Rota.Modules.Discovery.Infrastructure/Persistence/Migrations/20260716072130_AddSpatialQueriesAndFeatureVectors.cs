using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rota.Modules.Discovery.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddSpatialQueriesAndFeatureVectors : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "place_feature_vectors",
                schema: "discovery",
                columns: table => new
                {
                    place_id = table.Column<Guid>(type: "uuid", nullable: false),
                    version = table.Column<int>(type: "integer", nullable: false),
                    values = table.Column<float[]>(type: "real[]", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_place_feature_vectors", x => x.place_id);
                    table.ForeignKey(
                        name: "FK_place_feature_vectors_places_place_id",
                        column: x => x.place_id,
                        principalSchema: "discovery",
                        principalTable: "places",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_place_feature_vectors_version",
                schema: "discovery",
                table: "place_feature_vectors",
                column: "version");

            // ST_DWithin(location::geography, ...) yarıçap sorgusunun index kullanmasını sağlar.
            migrationBuilder.Sql(
                "CREATE INDEX ix_places_location_geography_gist ON discovery.places USING gist ((location::geography));");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP INDEX IF EXISTS discovery.ix_places_location_geography_gist");

            migrationBuilder.DropTable(
                name: "place_feature_vectors",
                schema: "discovery");
        }
    }
}
