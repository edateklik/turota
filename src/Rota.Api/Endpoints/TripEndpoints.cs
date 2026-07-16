using Rota.Api.Errors;
using Rota.Api.Security;
using Rota.Modules.Trip.Application.Contracts;

namespace Rota.Api.Endpoints;

public static class TripEndpoints
{
    public static IEndpointRouteBuilder MapTripEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/trips")
            .WithTags("Trips")
            .RequireAuthorization("User");

        group.MapGet("/", (
                int? page,
                int? pageSize,
                HttpContext context,
                ITripService service,
                CancellationToken cancellationToken) =>
                service.GetPageAsync(
                    context.User.GetRequiredUserId(),
                    page ?? 1,
                    pageSize ?? 20,
                    cancellationToken))
            .WithName("GetMyTrips")
            .WithSummary("Kullanıcının rotalarını sayfalı olarak getirir")
            .Produces<TripPageResponse>()
            .Produces<ApiProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json");

        group.MapGet("/{tripId:guid}", (
                Guid tripId,
                HttpContext context,
                ITripService service,
                CancellationToken cancellationToken) =>
                service.GetAsync(context.User.GetRequiredUserId(), tripId, cancellationToken))
            .WithName("GetTrip")
            .WithSummary("Timeline ve harita koordinatlarıyla rota detayını getirir")
            .Produces<TripResponse>()
            .Produces<ApiProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json");

        group.MapPost("/{tripId:guid}/cancel", (
                Guid tripId,
                HttpContext context,
                ITripService service,
                CancellationToken cancellationToken) =>
                service.CancelAsync(context.User.GetRequiredUserId(), tripId, cancellationToken))
            .WithName("CancelTrip")
            .WithSummary("Planlanmış rotayı iptal eder")
            .Produces<TripResponse>()
            .Produces<ApiProblemDetails>(StatusCodes.Status409Conflict, "application/problem+json");

        group.MapPost("/{tripId:guid}/complete", (
                Guid tripId,
                HttpContext context,
                ITripService service,
                CancellationToken cancellationToken) =>
                service.CompleteAsync(context.User.GetRequiredUserId(), tripId, cancellationToken))
            .WithName("CompleteTrip")
            .WithSummary("Planlanmış rotayı tamamlandı olarak işaretler")
            .Produces<TripResponse>()
            .Produces<ApiProblemDetails>(StatusCodes.Status409Conflict, "application/problem+json");

        return endpoints;
    }
}
