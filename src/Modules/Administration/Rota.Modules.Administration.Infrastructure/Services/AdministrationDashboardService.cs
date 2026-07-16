using Npgsql;
using Rota.Modules.Administration.Application.Contracts;

namespace Rota.Modules.Administration.Infrastructure.Services;

public sealed class AdministrationDashboardService(
    NpgsqlDataSource dataSource,
    TimeProvider timeProvider) : IAdministrationDashboardService
{
    private const string DashboardSql = """
        SELECT
            (SELECT count(*) FROM identity.users),
            (SELECT count(*) FROM discovery.neighborhoods),
            (SELECT count(*) FROM discovery.places),
            (SELECT count(*) FROM recommendation.recommendation_runs),
            (SELECT count(*) FROM recommendation.recommendation_runs WHERE status = 'Completed'),
            (SELECT count(*) FROM recommendation.recommendation_runs WHERE status = 'Failed'),
            (SELECT avg(EXTRACT(EPOCH FROM (completed_at - requested_at)) * 1000)::double precision
             FROM recommendation.recommendation_runs WHERE status = 'Completed'),
            (SELECT count(*) FROM trip.trips),
            (SELECT count(*) FROM trip.trips WHERE status = 'Planned'),
            (SELECT count(*) FROM trip.trips WHERE status = 'Completed'),
            (SELECT count(*) FROM trip.trips WHERE status = 'Cancelled'),
            (SELECT count(*) FROM recommendation.outbox_messages WHERE status = 'Failed');

        SELECT neighborhood_id, region_name, count(*)
        FROM recommendation.recommendation_runs
        WHERE status = 'Completed' AND neighborhood_id IS NOT NULL
        GROUP BY neighborhood_id, region_name
        ORDER BY count(*) DESC, region_name
        LIMIT 5;

        SELECT place_id, name, count(*)
        FROM recommendation.recommended_places
        GROUP BY place_id, name
        ORDER BY count(*) DESC, name
        LIMIT 5;
        """;

    public async Task<AdministrationDashboardResponse> GetAsync(CancellationToken cancellationToken = default)
    {
        await using var command = dataSource.CreateCommand(DashboardSql);
        command.CommandTimeout = 2;
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        await reader.ReadAsync(cancellationToken);
        var userCount = reader.GetInt64(0);
        var neighborhoodCount = reader.GetInt64(1);
        var placeCount = reader.GetInt64(2);
        var recommendationCount = reader.GetInt64(3);
        var completedRecommendationCount = reader.GetInt64(4);
        var failedRecommendationCount = reader.GetInt64(5);
        var averageDuration = reader.IsDBNull(6) ? (double?)null : reader.GetDouble(6);
        var tripCount = reader.GetInt64(7);
        var plannedTripCount = reader.GetInt64(8);
        var completedTripCount = reader.GetInt64(9);
        var cancelledTripCount = reader.GetInt64(10);
        var failedOutboxMessageCount = reader.GetInt64(11);

        await reader.NextResultAsync(cancellationToken);
        var topNeighborhoods = await ReadRankedAsync(reader, cancellationToken);
        await reader.NextResultAsync(cancellationToken);
        var topPlaces = await ReadRankedAsync(reader, cancellationToken);
        var terminalCount = completedRecommendationCount + failedRecommendationCount;
        var successRate = terminalCount == 0
            ? 0
            : Math.Round(completedRecommendationCount * 100d / terminalCount, 2);

        return new AdministrationDashboardResponse(
            userCount,
            neighborhoodCount,
            placeCount,
            recommendationCount,
            completedRecommendationCount,
            failedRecommendationCount,
            successRate,
            averageDuration is null ? null : Math.Round(averageDuration.Value, 2),
            tripCount,
            plannedTripCount,
            completedTripCount,
            cancelledTripCount,
            failedOutboxMessageCount,
            topNeighborhoods,
            topPlaces,
            timeProvider.GetUtcNow());
    }

    private static async Task<IReadOnlyList<RankedUsageResponse>> ReadRankedAsync(
        NpgsqlDataReader reader,
        CancellationToken cancellationToken)
    {
        var items = new List<RankedUsageResponse>();
        while (await reader.ReadAsync(cancellationToken))
            items.Add(new RankedUsageResponse(reader.GetGuid(0), reader.GetString(1), reader.GetInt64(2)));
        return items;
    }
}
