using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;
using Rota.Modules.Administration.Application.Contracts;
using Rota.Modules.Administration.Infrastructure.Services;

namespace Rota.Modules.Administration.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddAdministrationInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("AdministrationReadDb")
            ?? configuration.GetConnectionString("RecommendationDb")
            ?? throw new InvalidOperationException("ConnectionStrings:AdministrationReadDb yapılandırılmalıdır.");
        services.AddSingleton(_ => new NpgsqlDataSourceBuilder(connectionString).Build());
        services.AddScoped<IAdministrationDashboardService, AdministrationDashboardService>();
        services.AddScoped<IRecommendationSimulationService, RecommendationSimulationService>();
        return services;
    }
}
