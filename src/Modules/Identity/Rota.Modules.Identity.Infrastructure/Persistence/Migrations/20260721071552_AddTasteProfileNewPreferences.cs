using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rota.Modules.Identity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddTasteProfileNewPreferences : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "dietary_preference",
                schema: "identity",
                table: "taste_profiles",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "distance_preference",
                schema: "identity",
                table: "taste_profiles",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "dietary_preference",
                schema: "identity",
                table: "taste_profiles");

            migrationBuilder.DropColumn(
                name: "distance_preference",
                schema: "identity",
                table: "taste_profiles");
        }
    }
}
