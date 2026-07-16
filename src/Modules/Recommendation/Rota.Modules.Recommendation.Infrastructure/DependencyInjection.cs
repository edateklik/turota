using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Rota.Modules.Recommendation.Application.Contracts;
using Rota.Modules.Recommendation.Application.Services;
using Rota.Modules.Recommendation.Infrastructure.Integration;
using Rota.Modules.Recommendation.Infrastructure.Persistence;
using Rota.Modules.Recommendation.Infrastructure.Outbox;
using Rota.Modules.Recommendation.Infrastructure.Workers;

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
        var workerOptions = configuration.GetSection(RecommendationWorkerOptions.SectionName)
            .Get<RecommendationWorkerOptions>() ?? new RecommendationWorkerOptions();
        Validate(workerOptions);
        var outboxOptions = configuration.GetSection(OutboxWorkerOptions.SectionName)
            .Get<OutboxWorkerOptions>() ?? new OutboxWorkerOptions();
        Validate(outboxOptions);

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
        services.AddScoped<RecommendationJobProcessor>();
        services.AddScoped<RecommendationOutboxWriter>();
        services.AddScoped<RecommendationOutboxStore>();
        services.AddScoped<RecommendationOutboxDispatcher>();
        services.AddSingleton(fastApiOptions);
        services.AddSingleton(workerOptions);
        services.AddSingleton(outboxOptions);
        services.AddHostedService<RecommendationBackgroundWorker>();
        services.AddHostedService<RecommendationOutboxBackgroundWorker>();
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

    private static void Validate(RecommendationWorkerOptions options)
    {
        if (options.PollIntervalMilliseconds is < 50 or > 5_000)
            throw new InvalidOperationException("RecommendationWorker poll interval 50-5000 ms aralığında olmalıdır.");
        if (options.LeaseSeconds is < 5 or > 300)
            throw new InvalidOperationException("RecommendationWorker lease 5-300 saniye aralığında olmalıdır.");
        if (options.MaxAttempts is < 1 or > 10)
            throw new InvalidOperationException("RecommendationWorker max attempts 1-10 aralığında olmalıdır.");
        if (options.RetryDelayMilliseconds is < 50 or > 30_000)
            throw new InvalidOperationException("RecommendationWorker retry delay 50-30000 ms aralığında olmalıdır.");
    }

    private static void Validate(OutboxWorkerOptions options)
    {
        if (options.PollIntervalMilliseconds is < 50 or > 5_000)
            throw new InvalidOperationException("OutboxWorker poll interval 50-5000 ms aralığında olmalıdır.");
        if (options.LeaseSeconds is < 5 or > 300)
            throw new InvalidOperationException("OutboxWorker lease 5-300 saniye aralığında olmalıdır.");
        if (options.MaxAttempts is < 1 or > 20)
            throw new InvalidOperationException("OutboxWorker max attempts 1-20 aralığında olmalıdır.");
        if (options.RetryDelayMilliseconds is < 50 or > 30_000)
            throw new InvalidOperationException("OutboxWorker retry delay 50-30000 ms aralığında olmalıdır.");
        if (options.ProcessedRetentionHours is < 1 or > 8_760)
            throw new InvalidOperationException("OutboxWorker retention 1-8760 saat aralığında olmalıdır.");
        if (options.CleanupIntervalMinutes is < 1 or > 1_440)
            throw new InvalidOperationException("OutboxWorker cleanup interval 1-1440 dakika aralığında olmalıdır.");
    }
}
