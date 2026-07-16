using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Rota.Modules.Recommendation.Application.Contracts;
using Rota.Modules.Trip.Application.Contracts;
using Rota.Modules.Trip.Infrastructure.Events;
using Rota.Modules.Trip.Infrastructure.Persistence;
using Rota.Modules.Trip.Infrastructure.Services;

namespace Rota.Modules.Trip.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddTripInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("TripDb")
            ?? throw new InvalidOperationException("ConnectionStrings:TripDb yapılandırılmalıdır.");
        services.AddDbContextPool<TripDbContext>(options =>
            options.UseNpgsql(connectionString, npgsql =>
            {
                npgsql.MigrationsHistoryTable("__ef_migrations_history", "trip");
                npgsql.EnableRetryOnFailure(3);
                npgsql.CommandTimeout(2);
            }));
        services.AddScoped<ITripService, TripService>();
        services.AddScoped<IRecommendationEventHandler, RecommendationTripEventHandler>();
        return services;
    }
}
