using Microsoft.AspNetCore.Mvc;

namespace Rota.Api.Errors;

/// <summary>Tüm API hata yanıtlarında kullanılan RFC 7807 genişletmesi.</summary>
public class ApiProblemDetails : ProblemDetails
{
    public string ErrorCode { get; init; } = null!;
    public string TraceId { get; init; } = null!;
    public DateTimeOffset Timestamp { get; init; }
}

/// <summary>Alan bazlı validation hatalarını taşıyan standart hata yanıtı.</summary>
public sealed class ApiValidationProblemDetails(IDictionary<string, string[]> errors)
    : HttpValidationProblemDetails(errors)
{
    public string ErrorCode { get; init; } = "VALIDATION_ERROR";
    public string TraceId { get; init; } = null!;
    public DateTimeOffset Timestamp { get; init; }
}
