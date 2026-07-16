using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace Rota.Api.Observability;

public sealed class FastApiReadinessHealthCheck(IHttpClientFactory httpClientFactory) : IHealthCheck
{
    public const string HttpClientName = "FastApiReadiness";

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            using var response = await httpClientFactory.CreateClient(HttpClientName)
                .GetAsync("/health/ready", cancellationToken);
            return response.IsSuccessStatusCode
                ? HealthCheckResult.Healthy("FastAPI öneri servisi hazır.")
                : HealthCheckResult.Unhealthy($"FastAPI {(int)response.StatusCode} döndürdü.");
        }
        catch (Exception exception)
        {
            return HealthCheckResult.Unhealthy("FastAPI öneri servisi hazır değil.", exception);
        }
    }
}
