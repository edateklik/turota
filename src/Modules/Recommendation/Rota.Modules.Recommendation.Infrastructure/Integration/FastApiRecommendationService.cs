using System.Net;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Rota.Modules.Recommendation.Application.Contracts;
using Rota.Modules.Recommendation.Application.Errors;

namespace Rota.Modules.Recommendation.Infrastructure.Integration;

public sealed class FastApiRecommendationService(
    HttpClient httpClient,
    FastApiOptions options) : IRecommendationService
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web)
    {
        PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
        PropertyNameCaseInsensitive = true,
        Converters = { new JsonStringEnumConverter(JsonNamingPolicy.CamelCase) }
    };

    public async Task<AiRecommendationResult> GenerateAsync(
        AiRecommendationRequest request,
        CancellationToken cancellationToken = default)
    {
        using var message = new HttpRequestMessage(HttpMethod.Post, options.RecommendationPath)
        {
            Content = new StringContent(
                JsonSerializer.Serialize(request, JsonOptions),
                Encoding.UTF8,
                "application/json")
        };
        message.Headers.TryAddWithoutValidation("X-Correlation-ID", request.CorrelationId);

        HttpResponseMessage response;
        try
        {
            response = await httpClient.SendAsync(message, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
        }
        catch (OperationCanceledException exception) when (!cancellationToken.IsCancellationRequested)
        {
            throw new AiServiceTimeoutException(exception);
        }
        catch (HttpRequestException exception)
        {
            throw new AiServiceUnavailableException(exception);
        }

        using (response)
        {
            if (response.StatusCode is HttpStatusCode.RequestTimeout or HttpStatusCode.GatewayTimeout)
                throw new AiServiceTimeoutException();
            if ((int)response.StatusCode >= 500)
                throw new AiServiceUnavailableException();
            if (!response.IsSuccessStatusCode)
                throw new AiContractException($"AI servisi isteği reddetti (HTTP {(int)response.StatusCode}).");

            try
            {
                var result = await response.Content.ReadFromJsonAsync<AiRecommendationResult>(JsonOptions, cancellationToken)
                    ?? throw new AiContractException("AI servisi boş yanıt döndürdü.");
                Validate(result, request.AvailableMinutes);
                return result;
            }
            catch (JsonException exception)
            {
                throw new AiContractException("AI servis yanıtı beklenen JSON sözleşmesine uymuyor.", exception);
            }
        }
    }

    private static void Validate(AiRecommendationResult result, int availableMinutes)
    {
        if (string.IsNullOrWhiteSpace(result.ModelVersion) || result.ModelVersion.Length > 80)
            throw new AiContractException("AI model_version alanı geçersiz.");
        if (result.Region is null || result.Region.NeighborhoodId == Guid.Empty ||
            !double.IsFinite(result.Region.Score) || result.Region.Score is < 0 or > 1 ||
            string.IsNullOrWhiteSpace(result.Region.Name) || result.Region.Name.Length > 180 ||
            string.IsNullOrWhiteSpace(result.Region.Explanation) || result.Region.Explanation.Length > 2_000)
            throw new AiContractException("AI bölge önerisi geçersiz.");
        if (result.Places.Count is 0 or > 100 || result.Places.Any(x =>
                x.PlaceId == Guid.Empty || !double.IsFinite(x.Score) || x.Score is < 0 or > 1 ||
                string.IsNullOrWhiteSpace(x.Name) || x.Name.Length > 180 ||
                string.IsNullOrWhiteSpace(x.Explanation) || x.Explanation.Length > 2_000))
            throw new AiContractException("AI mekan önerileri geçersiz.");
        if (result.Timeline.Count is 0 or > 50 ||
            result.Timeline.Select(x => x.Sequence).Distinct().Count() != result.Timeline.Count ||
            result.Timeline.Sum(x => x.DurationMinutes) > availableMinutes ||
            result.Timeline.Any(x => x.Sequence <= 0 || x.PlaceId == Guid.Empty || x.DurationMinutes is <= 0 or > 720 ||
                string.IsNullOrWhiteSpace(x.PlaceName) || x.PlaceName.Length > 180 ||
                string.IsNullOrWhiteSpace(x.Explanation) || x.Explanation.Length > 2_000))
            throw new AiContractException("AI Timeline yanıtı geçersiz.");
        if (string.IsNullOrWhiteSpace(result.OverallExplanation) || result.OverallExplanation.Length > 4_000)
            throw new AiContractException("AI genel açıklaması geçersiz.");
    }
}
