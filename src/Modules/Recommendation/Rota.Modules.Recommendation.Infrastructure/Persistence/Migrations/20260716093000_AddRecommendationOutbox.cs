using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rota.Modules.Recommendation.Infrastructure.Persistence.Migrations;

[DbContext(typeof(RecommendationDbContext))]
[Migration("20260716093000_AddRecommendationOutbox")]
public sealed class AddRecommendationOutbox : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "outbox_messages",
            schema: "recommendation",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                aggregate_id = table.Column<Guid>(type: "uuid", nullable: false),
                type = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                payload = table.Column<string>(type: "jsonb", nullable: false),
                status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                occurred_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                attempt_count = table.Column<int>(type: "integer", nullable: false),
                processing_started_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                next_attempt_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                processed_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                last_error = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true)
            },
            constraints: table => table.PrimaryKey("PK_outbox_messages", x => x.id));

        migrationBuilder.CreateIndex(
            name: "ix_outbox_messages_dispatch_queue",
            schema: "recommendation",
            table: "outbox_messages",
            columns: new[] { "status", "next_attempt_at", "occurred_at" });
        migrationBuilder.CreateIndex(
            name: "ix_outbox_messages_processing_lease",
            schema: "recommendation",
            table: "outbox_messages",
            columns: new[] { "status", "processing_started_at" });
        migrationBuilder.CreateIndex(
            name: "ux_outbox_messages_aggregate_type",
            schema: "recommendation",
            table: "outbox_messages",
            columns: new[] { "aggregate_id", "type" },
            unique: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder) =>
        migrationBuilder.DropTable(name: "outbox_messages", schema: "recommendation");
}
