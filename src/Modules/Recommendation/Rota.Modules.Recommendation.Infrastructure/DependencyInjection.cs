using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Rota.Modules.Recommendation.Application.Contracts;
using Rota.Modules.Recommendation.Application.Services;
using Rota.Modules.Recommendation.Infrastructure.Integration;
using Rota.Modules.Recommendation.Infrastructure.Persistence;

namespace Rota.Modules.Recommendation.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddRecommendationInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("RecommendationDb")
            ?? throw new InvalidOperationException("ConnectionStrings:RecommendationDb yapılandırılmalıdır.");
        var fastApiOptions = configuration.GetRequiredSection(FastApiOptions.SectionName).Get<FastApiOptions>()
            ?? throw new InvalidOperationException("FastApi yapılandırması bulunamadı.");
        Validate(fastApiOptions);

        services.AddDbContextPool<RecommendationDbContext>(options =>
            options.UseNpgsql(connectionString, npgsql =>
            {
                npgsql.MigrationsHistoryTable("__ef_migrations_history", "recommendation");
                npgsql.EnableRetryOnFailure(3);
                npgsql.CommandTimeout(2);
            }));
        services.TryAddSingleton(TimeProvider.System);
        services.AddScoped<IRecommendationRepository, RecommendationRepository>();
        services.AddScoped<ITasteProfileProvider, IdentityTasteProfileProvider>();
        services.AddScoped<IRecommendationOrchestrator, RecommendationOrchestrator>();
        services.AddSingleton(fastApiOptions);
        services.AddHttpClient<IRecommendationService, FastApiRecommendationService>(client =>
        {
            client.BaseAddress = new Uri(fastApiOptions.BaseUrl, UriKind.Absolute);
            client.Timeout = TimeSpan.FromMilliseconds(fastApiOptions.TimeoutMilliseconds);
            client.DefaultRequestHeaders.UserAgent.ParseAdd("Rota-Api/1.0");
        });
        return services;
    }

    private static void Validate(FastApiOptions options)
    {
        if (!Uri.TryCreate(options.BaseUrl, UriKind.Absolute, out var uri) || uri.Scheme is not ("http" or "https"))
            throw new InvalidOperationException("FastApi:BaseUrl geçerli bir HTTP(S) adresi olmalıdır.");
        if (string.IsNullOrWhiteSpace(options.RecommendationPath) || !options.RecommendationPath.StartsWith('/'))
            throw new InvalidOperationException("FastApi:RecommendationPath '/' ile başlayan bir yol olmalıdır.");
        if (options.TimeoutMilliseconds is < 250 or > 1_800)
            throw new InvalidOperationException("FastApi timeout 250-1800 ms aralığında olmalıdır.");
    }
}
