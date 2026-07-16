namespace Rota.Modules.Recommendation.Application.Errors;

public abstract class RecommendationIntegrationException(string message, string errorCode, Exception? innerException = null)
    : Exception(message, innerException)
{
    public string ErrorCode { get; } = errorCode;
}

public sealed class AiServiceUnavailableException(Exception? innerException = null)
    : RecommendationIntegrationException("AI öneri servisine ulaşılamıyor.", "AI_SERVICE_UNAVAILABLE", innerException);

public sealed class AiServiceTimeoutException(Exception? innerException = null)
    : RecommendationIntegrationException("AI öneri servisi zaman aşımına uğradı.", "AI_SERVICE_TIMEOUT", innerException);

public sealed class AiContractException(string message, Exception? innerException = null)
    : RecommendationIntegrationException(message, "AI_INVALID_RESPONSE", innerException);
