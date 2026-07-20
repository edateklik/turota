using Rota.Modules.Discovery.Application.Admin;
using Rota.Modules.Discovery.Application.Features;
using Rota.Modules.Discovery.Application.Spatial;
using Rota.Api.Validation;

namespace Rota.Api.Endpoints;

public static class DiscoveryEndpoints
{
    public static IEndpointRouteBuilder MapDiscoveryEndpoints(this IEndpointRouteBuilder endpoints)
    {
        MapSpatialEndpoints(endpoints);
        MapAdminEndpoints(endpoints);
        return endpoints;
    }

    private static void MapSpatialEndpoints(IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/discovery").WithTags("Discovery");

        group.MapGet("/neighborhoods/{neighborhoodId:guid}/places", (
            Guid neighborhoodId,
            IPlaceDiscoveryService service,
            CancellationToken cancellationToken) =>
            service.GetInsideNeighborhoodAsync(neighborhoodId, cancellationToken));

        group.MapGet("/places/nearest", (
            double longitude,
            double latitude,
            int? limit,
            IPlaceDiscoveryService service,
            CancellationToken cancellationToken) =>
            service.GetNearestAsync(longitude, latitude, limit ?? 20, cancellationToken));

        group.MapGet("/places/within-radius", (
            double longitude,
            double latitude,
            double radiusKilometers,
            int? limit,
            IPlaceDiscoveryService service,
            CancellationToken cancellationToken) =>
            service.GetWithinRadiusAsync(longitude, latitude, radiusKilometers, limit ?? 100, cancellationToken));

        group.MapGet("/neighborhoods/nearby", (
            double longitude,
            double latitude,
            int? limit,
            IPlaceDiscoveryService service,
            CancellationToken cancellationToken) =>
            service.GetNearbyNeighborhoodsAsync(longitude, latitude, limit ?? 5, cancellationToken));
        group.MapGet("/weather", (
            double? latitude,
            double? longitude,
            Rota.Modules.Discovery.Application.Features.Weather.IWeatherService service,
            CancellationToken cancellationToken) =>
            service.GetSevenDayForecastAsync(latitude ?? 41.0082, longitude ?? 28.9784, cancellationToken));
    }

    private static void MapAdminEndpoints(IEndpointRouteBuilder endpoints)
    {
        var admin = endpoints.MapGroup("/api/admin").WithTags("Discovery Admin").RequireAuthorization("Admin");

        var cities = admin.MapGroup("/cities");
        cities.MapGet("/", (ICityAdminService service, CancellationToken ct) => service.GetAllAsync(ct));
        cities.MapGet("/{id:guid}", async (Guid id, ICityAdminService service, CancellationToken ct) =>
            await service.GetByIdAsync(id, ct) is { } item ? Results.Ok(item) : Results.NotFound());
        cities.MapPost("/", async (SaveCityRequest request, ICityAdminService service, CancellationToken ct) =>
        {
            var item = await service.CreateAsync(request, ct);
            return Results.Created($"/api/admin/cities/{item.Id}", item);
        }).AddEndpointFilter<DataAnnotationsValidationFilter<SaveCityRequest>>();
        cities.MapPut("/{id:guid}", async (Guid id, SaveCityRequest request, ICityAdminService service, CancellationToken ct) =>
            await service.UpdateAsync(id, request, ct) is { } item ? Results.Ok(item) : Results.NotFound())
            .AddEndpointFilter<DataAnnotationsValidationFilter<SaveCityRequest>>();
        cities.MapDelete("/{id:guid}", async (Guid id, ICityAdminService service, CancellationToken ct) =>
            await service.DeleteAsync(id, ct) ? Results.NoContent() : Results.NotFound());

        var neighborhoods = admin.MapGroup("/neighborhoods");
        neighborhoods.MapGet("/", (INeighborhoodAdminService service, CancellationToken ct) => service.GetAllAsync(ct));
        neighborhoods.MapGet("/{id:guid}", async (Guid id, INeighborhoodAdminService service, CancellationToken ct) =>
            await service.GetByIdAsync(id, ct) is { } item ? Results.Ok(item) : Results.NotFound());
        neighborhoods.MapPost("/", async (SaveNeighborhoodRequest request, INeighborhoodAdminService service, CancellationToken ct) =>
        {
            var item = await service.CreateAsync(request, ct);
            return Results.Created($"/api/admin/neighborhoods/{item.Id}", item);
        }).AddEndpointFilter<DataAnnotationsValidationFilter<SaveNeighborhoodRequest>>();
        neighborhoods.MapPut("/{id:guid}", async (Guid id, SaveNeighborhoodRequest request, INeighborhoodAdminService service, CancellationToken ct) =>
            await service.UpdateAsync(id, request, ct) is { } item ? Results.Ok(item) : Results.NotFound())
            .AddEndpointFilter<DataAnnotationsValidationFilter<SaveNeighborhoodRequest>>();
        neighborhoods.MapDelete("/{id:guid}", async (Guid id, INeighborhoodAdminService service, CancellationToken ct) =>
            await service.DeleteAsync(id, ct) ? Results.NoContent() : Results.NotFound());

        var places = admin.MapGroup("/places");
        places.MapGet("/", (IPlaceAdminService service, CancellationToken ct) => service.GetAllAsync(ct));
        places.MapGet("/{id:guid}", async (Guid id, IPlaceAdminService service, CancellationToken ct) =>
            await service.GetByIdAsync(id, ct) is { } item ? Results.Ok(item) : Results.NotFound());
        places.MapPost("/", async (SavePlaceRequest request, IPlaceAdminService service, CancellationToken ct) =>
        {
            var item = await service.CreateAsync(request, ct);
            return Results.Created($"/api/admin/places/{item.Id}", item);
        }).AddEndpointFilter<DataAnnotationsValidationFilter<SavePlaceRequest>>();
        places.MapPut("/{id:guid}", async (Guid id, SavePlaceRequest request, IPlaceAdminService service, CancellationToken ct) =>
            await service.UpdateAsync(id, request, ct) is { } item ? Results.Ok(item) : Results.NotFound())
            .AddEndpointFilter<DataAnnotationsValidationFilter<SavePlaceRequest>>();
        places.MapDelete("/{id:guid}", async (Guid id, IPlaceAdminService service, CancellationToken ct) =>
            await service.DeleteAsync(id, ct) ? Results.NoContent() : Results.NotFound());
        places.MapGet("/{id:guid}/feature-vector", async (Guid id, IPlaceFeatureVectorService service, CancellationToken ct) =>
            await service.GetAsync(id, ct) is { } vector ? Results.Ok(vector) : Results.NotFound());
        places.MapPost("/{id:guid}/feature-vector/rebuild", (Guid id, IPlaceFeatureVectorService service, CancellationToken ct) =>
            service.RebuildAsync(id, ct));
        places.MapPost("/feature-vectors/rebuild", (IPlaceFeatureVectorService service, CancellationToken ct) =>
            service.RebuildAllAsync(ct));
        places.MapGet("/feature-vectors/schema", (IPlaceFeatureVectorService service, CancellationToken ct) =>
            service.GetSchemaAsync(ct));

        var categories = admin.MapGroup("/categories");
        categories.MapGet("/", (ICategoryAdminService service, CancellationToken ct) => service.GetAllAsync(ct));
        categories.MapGet("/{id:guid}", async (Guid id, ICategoryAdminService service, CancellationToken ct) =>
            await service.GetByIdAsync(id, ct) is { } item ? Results.Ok(item) : Results.NotFound());
        categories.MapPost("/", async (SaveCategoryRequest request, ICategoryAdminService service, CancellationToken ct) =>
        {
            var item = await service.CreateAsync(request, ct);
            return Results.Created($"/api/admin/categories/{item.Id}", item);
        }).AddEndpointFilter<DataAnnotationsValidationFilter<SaveCategoryRequest>>();
        categories.MapPut("/{id:guid}", async (Guid id, SaveCategoryRequest request, ICategoryAdminService service, CancellationToken ct) =>
            await service.UpdateAsync(id, request, ct) is { } item ? Results.Ok(item) : Results.NotFound())
            .AddEndpointFilter<DataAnnotationsValidationFilter<SaveCategoryRequest>>();
        categories.MapDelete("/{id:guid}", async (Guid id, ICategoryAdminService service, CancellationToken ct) =>
            await service.DeleteAsync(id, ct) ? Results.NoContent() : Results.NotFound());

        var tags = admin.MapGroup("/tags");
        tags.MapGet("/", (ITagAdminService service, CancellationToken ct) => service.GetAllAsync(ct));
        tags.MapGet("/{id:guid}", async (Guid id, ITagAdminService service, CancellationToken ct) =>
            await service.GetByIdAsync(id, ct) is { } item ? Results.Ok(item) : Results.NotFound());
        tags.MapPost("/", async (SaveTagRequest request, ITagAdminService service, CancellationToken ct) =>
        {
            var item = await service.CreateAsync(request, ct);
            return Results.Created($"/api/admin/tags/{item.Id}", item);
        }).AddEndpointFilter<DataAnnotationsValidationFilter<SaveTagRequest>>();
        tags.MapPut("/{id:guid}", async (Guid id, SaveTagRequest request, ITagAdminService service, CancellationToken ct) =>
            await service.UpdateAsync(id, request, ct) is { } item ? Results.Ok(item) : Results.NotFound())
            .AddEndpointFilter<DataAnnotationsValidationFilter<SaveTagRequest>>();
        tags.MapDelete("/{id:guid}", async (Guid id, ITagAdminService service, CancellationToken ct) =>
            await service.DeleteAsync(id, ct) ? Results.NoContent() : Results.NotFound());
    }
}
