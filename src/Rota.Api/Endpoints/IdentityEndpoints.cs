using Microsoft.AspNetCore.Mvc;
using Rota.Api.Security;
using Rota.Api.Errors;
using Rota.Modules.Identity.Application.Contracts;
using Rota.Api.Validation;

namespace Rota.Api.Endpoints;

public static class IdentityEndpoints
{
    public static IEndpointRouteBuilder MapIdentityEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var auth = endpoints.MapGroup("/api/identity").WithTags("Identity");

        auth.MapPost("/register", async (
                RegisterRequest request,
                IIdentityService service,
                CancellationToken cancellationToken) =>
            {
                var response = await service.RegisterAsync(request, cancellationToken);
                return Results.Created($"/api/identity/users/{response.User.Id}", response);
            })
            .AllowAnonymous()
            .RequireRateLimiting("authentication")
            .AddEndpointFilter<DataAnnotationsValidationFilter<RegisterRequest>>()
            .WithName("Register")
            .WithSummary("Yeni kullanıcı hesabı oluşturur")
            .WithDescription("Kullanıcı rolüyle hesap ve boş TasteProfile oluşturur; erişim JWT'sini döndürür.")
            .Produces<AuthResponse>(StatusCodes.Status201Created)
            .Produces<ApiValidationProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")
            .Produces<ApiProblemDetails>(StatusCodes.Status409Conflict, "application/problem+json");

        auth.MapPost("/login", async (
                LoginRequest request,
                IIdentityService service,
                CancellationToken cancellationToken) =>
            {
                var response = await service.LoginAsync(request, cancellationToken);
                return Results.Ok(response);
            })
            .AllowAnonymous()
            .RequireRateLimiting("authentication")
            .AddEndpointFilter<DataAnnotationsValidationFilter<LoginRequest>>()
            .WithName("Login")
            .WithSummary("E-posta ve parola ile oturum açar")
            .WithDescription("Bearer access token ve frontend için kullanıcı özetini döndürür.")
            .Produces<AuthResponse>()
            .Produces<ApiValidationProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")
            .Produces<ApiProblemDetails>(StatusCodes.Status401Unauthorized, "application/problem+json");

        auth.MapGet("/me", (
                HttpContext context,
                IIdentityService service,
                CancellationToken cancellationToken) =>
                service.GetUserAsync(context.User.GetRequiredUserId(), cancellationToken))
            .RequireAuthorization("User")
            .WithName("GetCurrentUser")
            .WithSummary("Oturum açmış kullanıcıyı getirir")
            .Produces<UserResponse>()
            .Produces(StatusCodes.Status401Unauthorized);

        auth.MapPut("/me/profile-photo", async (
                IFormFile file,
                HttpContext context,
                IProfilePhotoService service,
                CancellationToken cancellationToken) =>
            {
                await using var content = file.OpenReadStream();
                return Results.Ok(await service.UploadAsync(
                    context.User.GetRequiredUserId(),
                    content,
                    file.ContentType,
                    file.Length,
                    cancellationToken));
            })
            .RequireAuthorization("User")
            .DisableAntiforgery()
            .WithName("UploadProfilePhoto")
            .Accepts<IFormFile>("multipart/form-data")
            .Produces<ProfilePhotoResponse>()
            .Produces<ApiProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")
            .Produces(StatusCodes.Status401Unauthorized);

        auth.MapDelete("/me/profile-photo", (
                HttpContext context,
                IProfilePhotoService service,
                CancellationToken cancellationToken) =>
                service.DeleteAsync(context.User.GetRequiredUserId(), cancellationToken))
            .RequireAuthorization("User")
            .WithName("DeleteProfilePhoto")
            .Produces<ProfilePhotoResponse>()
            .Produces(StatusCodes.Status401Unauthorized);

        auth.MapGet("/me/taste-profile", (
                HttpContext context,
                IIdentityService service,
                CancellationToken cancellationToken) =>
                service.GetTasteProfileAsync(context.User.GetRequiredUserId(), cancellationToken))
            .RequireAuthorization("User")
            .WithName("GetTasteProfile")
            .WithSummary("Kullanıcının zevk profilini getirir")
            .Produces<TasteProfileResponse>()
            .Produces(StatusCodes.Status401Unauthorized);

        auth.MapPut("/me/taste-profile", (
                UpdateTasteProfileRequest request,
                HttpContext context,
                IIdentityService service,
                CancellationToken cancellationToken) =>
                service.UpdateTasteProfileAsync(context.User.GetRequiredUserId(), request, cancellationToken))
            .RequireAuthorization("User")
            .WithName("UpdateTasteProfile")
            .WithSummary("Kullanıcının zevk profilini günceller")
            .WithDescription("Kategori/etiket kimlikleri Discovery modülüne ait gevşek referanslardır.")
            .Produces<TasteProfileResponse>()
            .Produces<ApiProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")
            .Produces(StatusCodes.Status401Unauthorized);

        return endpoints;
    }
}
