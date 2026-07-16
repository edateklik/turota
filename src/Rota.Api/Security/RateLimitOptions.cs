namespace Rota.Api.Security;

public sealed class RateLimitOptions
{
    public int WindowSeconds { get; init; } = 60;
    public int GlobalPermitLimit { get; init; } = 120;
    public int AuthenticationPermitLimit { get; init; } = 10;
    public int RecommendationPermitLimit { get; init; } = 20;
    public int AdminSimulationPermitLimit { get; init; } = 10;

    public void Validate()
    {
        if (WindowSeconds is < 1 or > 3600)
            throw new InvalidOperationException("RateLimits:WindowSeconds 1-3600 aralığında olmalıdır.");
        if (GlobalPermitLimit < 1 || AuthenticationPermitLimit < 1
            || RecommendationPermitLimit < 1 || AdminSimulationPermitLimit < 1)
            throw new InvalidOperationException("Rate limit permit değerleri pozitif olmalıdır.");
    }
}
