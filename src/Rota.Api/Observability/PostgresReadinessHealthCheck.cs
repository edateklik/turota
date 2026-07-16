using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Rota.Modules.Discovery.Infrastructure.Persistence;

namespace Rota.Api.Observability;

public sealed class PostgresReadinessHealthCheck(DiscoveryDbContext dbContext) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            return await dbContext.Database.CanConnectAsync(cancellationToken)
                ? HealthCheckResult.Healthy("PostgreSQL bağlantısı hazır.")
                : HealthCheckResult.Unhealthy("PostgreSQL bağlantısı kurulamadı.");
        }
        catch (Exception exception)
        {
            return HealthCheckResult.Unhealthy("PostgreSQL hazır değil.", exception);
        }
    }
}
