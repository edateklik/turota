namespace Rota.Modules.Recommendation.Infrastructure.Integration;

public sealed class FastApiOptions
{
    public const string SectionName = "FastApi";

    public string BaseUrl { get; init; } = string.Empty;
    public string RecommendationPath { get; init; } = "/api/v1/recommendations/generate";
    public int TimeoutMilliseconds { get; init; } = 1_500;
    public string ServiceApiKey { get; init; } = string.Empty;
}
