using Microsoft.AspNetCore.Mvc;
using Rota.Api.Security;
using Rota.Api.Errors;
using Rota.Api.Validation;
using Rota.Modules.Recommendation.Application.Contracts;

namespace Rota.Api.Endpoints;

public static class RecommendationEndpoints
{
    public static IEndpointRouteBuilder MapRecommendationEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/recommendations")
            .WithTags("Recommendations")
            .RequireAuthorization("User");

        group.MapPost("/generate", async (
                GenerateRecommendationRequest request,
                HttpContext context,
                IRecommendationOrchestrator orchestrator,
                CancellationToken cancellationToken) =>
            {
                var result = await orchestrator.EnqueueAsync(
                    context.User.GetRequiredUserId(),
                    request,
                    context.TraceIdentifier,
                    cancellationToken);
                return Results.Accepted(result.StatusUrl, result);
            })
            .AddEndpointFilter<DataAnnotationsValidationFilter<GenerateRecommendationRequest>>()
            .WithName("GenerateRecommendation")
            .WithSummary("Asenkron AI öneri çalışması başlatır")
            .WithDescription("İsteği kalıcı kuyruğa alır ve 202 ile durum URL'sini döndürür. Sonuç SignalR veya durum endpoint'i üzerinden izlenir.")
            .Produces<RecommendationAcceptedResponse>(StatusCodes.Status202Accepted)
            .Produces<ApiValidationProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json");

        group.MapGet("/{runId:guid}", (
                Guid runId,
                HttpContext context,
                IRecommendationOrchestrator orchestrator,
                CancellationToken cancellationToken) =>
                orchestrator.GetAsync(context.User.GetRequiredUserId(), runId, cancellationToken))
            .WithName("GetRecommendation")
            .WithSummary("Öneri çalışmasının durumunu ve tamamlandıysa sonucunu getirir")
            .Produces<RecommendationRunResponse>()
            .Produces<ApiProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json");

        group.MapGet("/me/latest", (
                HttpContext context,
                IRecommendationOrchestrator orchestrator,
                CancellationToken cancellationToken) =>
                orchestrator.GetLatestAsync(context.User.GetRequiredUserId(), cancellationToken))
            .WithName("GetLatestRecommendation")
            .WithSummary("Kullanıcının son tamamlanmış önerisini getirir")
            .Produces<RecommendationResponse>()
            .Produces<ApiProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json");

        return endpoints;
    }
}
