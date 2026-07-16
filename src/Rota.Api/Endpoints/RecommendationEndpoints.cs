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
                var result = await orchestrator.GenerateAsync(
                    context.User.GetRequiredUserId(),
                    request,
                    context.TraceIdentifier,
                    cancellationToken);
                return Results.Created($"/api/recommendations/{result.RunId}", result);
            })
            .AddEndpointFilter<DataAnnotationsValidationFilter<GenerateRecommendationRequest>>()
            .WithName("GenerateRecommendation")
            .WithSummary("TasteProfile kullanarak AI öneri paketi oluşturur")
            .WithDescription("FastAPI'den bölge, mekan, Timeline ve Explainable AI açıklamalarını alır ve sonucu PostgreSQL'e kaydeder.")
            .Produces<RecommendationResponse>(StatusCodes.Status201Created)
            .Produces<ApiValidationProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")
            .Produces<ApiProblemDetails>(StatusCodes.Status502BadGateway, "application/problem+json")
            .Produces<ApiProblemDetails>(StatusCodes.Status503ServiceUnavailable, "application/problem+json")
            .Produces<ApiProblemDetails>(StatusCodes.Status504GatewayTimeout, "application/problem+json");

        group.MapGet("/{runId:guid}", (
                Guid runId,
                HttpContext context,
                IRecommendationOrchestrator orchestrator,
                CancellationToken cancellationToken) =>
                orchestrator.GetAsync(context.User.GetRequiredUserId(), runId, cancellationToken))
            .WithName("GetRecommendation")
            .WithSummary("Kaydedilmiş öneri sonucunu getirir")
            .Produces<RecommendationResponse>()
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
