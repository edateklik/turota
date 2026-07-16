using System.Diagnostics;

namespace Rota.Api.Observability;

public sealed class RequestTelemetryMiddleware(RequestDelegate next, ILogger<RequestTelemetryMiddleware> logger)
{
    private const string CorrelationHeader = "X-Correlation-ID";

    public async Task InvokeAsync(HttpContext context)
    {
        var suppliedCorrelationId = context.Request.Headers[CorrelationHeader].FirstOrDefault();
        var correlationId = IsValidCorrelationId(suppliedCorrelationId)
            ? suppliedCorrelationId!
            : context.TraceIdentifier;

        context.TraceIdentifier = correlationId;
        context.Response.Headers[CorrelationHeader] = correlationId;

        using var scope = logger.BeginScope(new Dictionary<string, object>
        {
            ["CorrelationId"] = correlationId,
            ["TraceId"] = Activity.Current?.TraceId.ToString() ?? string.Empty
        });

        var startedAt = Stopwatch.GetTimestamp();
        try
        {
            await next(context);
        }
        finally
        {
            var elapsedMs = Stopwatch.GetElapsedTime(startedAt).TotalMilliseconds;
            logger.Log(
                context.Response.StatusCode >= 500 ? LogLevel.Error : LogLevel.Information,
                "HTTP {Method} {Path} completed {StatusCode} in {ElapsedMilliseconds:F1} ms",
                context.Request.Method,
                context.Request.Path.Value,
                context.Response.StatusCode,
                elapsedMs);
        }
    }

    private static bool IsValidCorrelationId(string? value) =>
        !string.IsNullOrWhiteSpace(value)
        && value.Length <= 100
        && value.All(character => char.IsLetterOrDigit(character) || character is '-' or '_' or '.');
}
