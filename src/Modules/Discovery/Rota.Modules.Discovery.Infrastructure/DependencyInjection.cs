using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Rota.Modules.Discovery.Infrastructure.Persistence;
using Rota.Modules.Discovery.Infrastructure.Quality;
using Rota.Modules.Discovery.Application.Admin;
using Rota.Modules.Discovery.Application.Features;
using Rota.Modules.Discovery.Application.Spatial;
using Rota.Modules.Discovery.Infrastructure.Admin;
using Rota.Modules.Discovery.Infrastructure.Features;
using Rota.Modules.Discovery.Infrastructure.Spatial;
using Rota.Modules.Discovery.Application.Features.Weather;
using Rota.Modules.Discovery.Infrastructure.Features.Weather;

namespace Rota.Modules.Discovery.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddDiscoveryInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("DiscoveryDb")
            ?? throw new InvalidOperationException("ConnectionStrings:DiscoveryDb yapılandırılmalıdır.");

        services.AddDbContextPool<DiscoveryDbContext>(options =>
            options.UseNpgsql(connectionString, npgsql =>
            {
                npgsql.UseNetTopologySuite();
                npgsql.MigrationsHistoryTable("__ef_migrations_history", "discovery");
                npgsql.EnableRetryOnFailure(3);
                npgsql.CommandTimeout(2);
            }));
        services.AddScoped<DiscoveryDataQualityService>();
        services.AddScoped<PostGisSpatialPlaceRepository>();
        services.AddScoped<ISpatialPlaceRepository>(provider => provider.GetRequiredService<PostGisSpatialPlaceRepository>());
        services.AddScoped<IPlaceLocationReader>(provider => provider.GetRequiredService<PostGisSpatialPlaceRepository>());
        services.AddScoped<IPlaceDiscoveryService, PlaceDiscoveryService>();
        services.AddScoped<ICityAdminService, CityAdminService>();
        services.AddScoped<INeighborhoodAdminService, NeighborhoodAdminService>();
        services.AddScoped<IPlaceAdminService, PlaceAdminService>();
        services.AddScoped<ICategoryAdminService, CategoryAdminService>();
        services.AddScoped<ITagAdminService, TagAdminService>();
        services.AddScoped<IPlaceFeatureVectorService, PlaceFeatureVectorService>();
        services.AddHttpClient<IWeatherService, OpenMeteoWeatherService>();

        return services;
    }
}
