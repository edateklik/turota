using Rota.Api.Errors;
using Rota.Api.Validation;
using Rota.Modules.Administration.Application.Contracts;
using Rota.Api.Security;
using Rota.Modules.Identity.Application.Contracts;

namespace Rota.Api.Endpoints;

public static class AdministrationEndpoints
{
    public static IEndpointRouteBuilder MapAdministrationEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/admin")
            .WithTags("Administration")
            .RequireAuthorization("Admin");

        group.MapGet("/dashboard", (
                IAdministrationDashboardService service,
                CancellationToken cancellationToken) =>
                service.GetAsync(cancellationToken))
            .WithName("GetAdministrationDashboard")
            .WithSummary("Admin dashboard sayaçlarını ve en çok önerilen kayıtları getirir")
            .Produces<AdministrationDashboardResponse>()
            .Produces<ApiProblemDetails>(StatusCodes.Status401Unauthorized, "application/problem+json")
            .Produces<ApiProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json");

        group.MapGet("/users", (
                int? page,
                int? pageSize,
                IAdminIdentityService service,
                CancellationToken cancellationToken) =>
                service.GetPageAsync(page ?? 1, pageSize ?? 20, cancellationToken))
            .WithName("GetAdministrationUsers")
            .WithSummary("Kullanıcıları rol ve erişim durumlarıyla sayfalı getirir")
            .Produces<AdminUserPageResponse>();

        group.MapPut("/users/{userId:guid}/access", (
                Guid userId,
                UpdateUserAccessRequest request,
                HttpContext context,
                IAdminIdentityService service,
                CancellationToken cancellationToken) =>
                service.UpdateAccessAsync(
                    context.User.GetRequiredUserId(),
                    userId,
                    request,
                    cancellationToken))
            .AddEndpointFilter<DataAnnotationsValidationFilter<UpdateUserAccessRequest>>()
            .WithName("UpdateAdministrationUserAccess")
            .WithSummary("Kullanıcının rolünü ve aktiflik durumunu güvenli biçimde günceller")
            .Produces<AdminUserResponse>()
            .Produces<ApiProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")
            .Produces<ApiProblemDetails>(StatusCodes.Status409Conflict, "application/problem+json");

        group.MapPost("/simulations/recommendation", (
                RecommendationSimulationRequest request,
                HttpContext context,
                IRecommendationSimulationService service,
                CancellationToken cancellationToken) =>
                service.SimulateAsync(request, context.TraceIdentifier, cancellationToken))
            .RequireRateLimiting("admin-simulation")
            .AddEndpointFilter<DataAnnotationsValidationFilter<RecommendationSimulationRequest>>()
            .WithName("SimulateRecommendation")
            .WithSummary("TasteProfile senaryosunu kalıcı kayıt oluşturmadan FastAPI üzerinde çalıştırır")
            .WithDescription("Yanıttaki persisted alanı her zaman false değerindedir; Recommendation ve Trip tabloları değiştirilmez.")
            .Produces<RecommendationSimulationResponse>()
            .Produces<ApiValidationProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")
            .Produces<ApiProblemDetails>(StatusCodes.Status502BadGateway, "application/problem+json")
            .Produces<ApiProblemDetails>(StatusCodes.Status503ServiceUnavailable, "application/problem+json");

        return endpoints;
    }
}
