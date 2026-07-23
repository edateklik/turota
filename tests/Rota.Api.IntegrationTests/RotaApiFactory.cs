using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.EntityFrameworkCore;
using System.Collections.Concurrent;
using Rota.Modules.Recommendation.Application.Contracts;
using Rota.Modules.Recommendation.Application.Errors;
using Rota.Modules.Recommendation.Infrastructure.Outbox;
using Rota.Modules.Recommendation.Infrastructure.Persistence;
using Rota.Modules.Identity.Infrastructure.Persistence;
using Testcontainers.PostgreSql;
using Xunit;

namespace Rota.Api.IntegrationTests;

public sealed class RotaApiFactory : WebApplicationFactory<Program>, IAsyncLifetime
{
    private readonly string _profilePhotoStoragePath = Path.Combine(
        Path.GetTempPath(),
        $"rota-profile-photo-tests-{Guid.NewGuid():N}");
    private readonly PostgreSqlContainer _postgres = new PostgreSqlBuilder("postgis/postgis:16-3.4-alpine")
        .WithDatabase("rota_tests")
        .WithUsername("rota_tests")
        .WithPassword("rota_tests_password")
        .Build();

    public Task InitializeAsync() => _postgres.StartAsync();

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        var connectionString = _postgres.GetConnectionString();
        builder.UseSetting("ConnectionStrings:DiscoveryDb", connectionString);
        builder.UseSetting("ConnectionStrings:IdentityDb", connectionString);
        builder.UseSetting("ConnectionStrings:RecommendationDb", connectionString);
        builder.UseSetting("ConnectionStrings:TripDb", connectionString);
        builder.UseSetting("ConnectionStrings:AdministrationReadDb", connectionString);
        builder.UseSetting("Database:ApplyMigrationsOnStartup", "true");
        builder.UseSetting("Jwt:Issuer", "Rota.Api.Tests");
        builder.UseSetting("Jwt:Audience", "Rota.Clients.Tests");
        builder.UseSetting("Jwt:SigningKey", "rota-integration-tests-signing-key-2026-safe");
        builder.UseSetting("Jwt:ExpirationMinutes", "15");
        builder.UseSetting("FastApi:BaseUrl", "http://127.0.0.1:1");
        builder.UseSetting("FastApi:RecommendationPath", "/api/v1/recommendations/generate");
        builder.UseSetting("FastApi:TimeoutMilliseconds", "500");
        builder.UseSetting("FastApi:ServiceApiKey", "rota-integration-fastapi-service-key-2026");
        builder.UseSetting("RecommendationWorker:PollIntervalMilliseconds", "50");
        builder.UseSetting("RecommendationWorker:LeaseSeconds", "5");
        builder.UseSetting("RecommendationWorker:MaxAttempts", "3");
        builder.UseSetting("RecommendationWorker:RetryDelayMilliseconds", "50");
        builder.UseSetting("OutboxWorker:PollIntervalMilliseconds", "50");
        builder.UseSetting("OutboxWorker:LeaseSeconds", "5");
        builder.UseSetting("OutboxWorker:MaxAttempts", "3");
        builder.UseSetting("OutboxWorker:RetryDelayMilliseconds", "50");
        builder.UseSetting("Logging:LogLevel:Default", "Warning");
        builder.UseSetting("Logging:LogLevel:Microsoft.EntityFrameworkCore", "Warning");
        builder.UseSetting("ProfilePhotos:RootPath", _profilePhotoStoragePath);
        builder.UseSetting("ProfilePhotos:RequestPath", "/uploads/profile-photos");
        builder.ConfigureServices(services =>
        {
            services.RemoveAll<IRecommendationService>();
            services.AddSingleton<IRecommendationService, FakeRecommendationService>();
            services.AddSingleton<IRecommendationEventHandler, FlakyRecommendationEventHandler>();
        });
    }

    public async Task<OutboxProbe?> FindOutboxAsync(Guid aggregateId)
    {
        await using var scope = Services.CreateAsyncScope();
        return await scope.ServiceProvider.GetRequiredService<RecommendationDbContext>()
            .OutboxMessages
            .AsNoTracking()
            .Where(message => message.AggregateId == aggregateId)
            .Select(message => new OutboxProbe(
                message.Type,
                message.Status.ToString(),
                message.AttemptCount,
                message.ProcessedAt))
            .SingleOrDefaultAsync();
    }

    public async Task PromoteToAdminAsync(string email)
    {
        await using var scope = Services.CreateAsyncScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<IdentityDbContext>();
        var normalizedEmail = email.Trim().ToUpperInvariant();
        var affected = await dbContext.Database.ExecuteSqlInterpolatedAsync(
            $"UPDATE identity.users SET role = 'Admin' WHERE normalized_email = {normalizedEmail}");
        if (affected != 1) throw new InvalidOperationException("Integration test admin kullanıcısı bulunamadı.");
    }

    public async Task<int> GetRecommendationRunCountAsync()
    {
        await using var scope = Services.CreateAsyncScope();
        return await scope.ServiceProvider.GetRequiredService<RecommendationDbContext>()
            .RecommendationRuns.CountAsync();
    }

    async Task IAsyncLifetime.DisposeAsync()
    {
        await base.DisposeAsync();
        await _postgres.DisposeAsync();
        if (Directory.Exists(_profilePhotoStoragePath))
            Directory.Delete(_profilePhotoStoragePath, recursive: true);
    }
}

public sealed record OutboxProbe(string Type, string Status, int AttemptCount, DateTimeOffset? ProcessedAt);

internal sealed class FakeRecommendationService : IRecommendationService
{
    public async Task<AiRecommendationResult> GenerateAsync(
        AiRecommendationRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request.AvailableMinutes == 63)
            throw new AiServiceUnavailableException();
        await Task.Delay(750, cancellationToken);
        return new AiRecommendationResult
        {
            ModelVersion = "integration-test-v1",
            Region = new AiRegionRecommendation(
                Guid.Parse("20000000-0000-0000-0000-000000000001"),
                "Caferağa",
                0.94,
                "Test bölge açıklaması"),
            Places =
            [
                new AiPlaceRecommendation(
                    Guid.Parse("50000000-0000-0000-0000-000000000001"),
                    "Moda Kahve Noktası",
                    0.96,
                    "Test mekan açıklaması")
            ],
            Timeline =
            [
                new AiTimelineRecommendation(
                    1,
                    Guid.Parse("50000000-0000-0000-0000-000000000001"),
                    "Moda Kahve Noktası",
                    new TimeOnly(9, 0),
                    60,
                    "Test rota açıklaması")
            ],
            OverallExplanation = "Integration test açıklaması"
        };
    }
}

internal sealed class FlakyRecommendationEventHandler : IRecommendationEventHandler
{
    private readonly ConcurrentDictionary<(Guid RunId, string Type), int> _attempts = new();

    public Task HandleCompletedAsync(
        RecommendationCompletedEvent notification,
        CancellationToken cancellationToken = default) =>
        PublishAsync(notification.RunId, RecommendationOutboxTypes.Completed);

    public Task HandleFailedAsync(
        RecommendationFailedEvent notification,
        CancellationToken cancellationToken = default) =>
        PublishAsync(notification.RunId, RecommendationOutboxTypes.Failed);

    private Task PublishAsync(Guid runId, string type)
    {
        var attempt = _attempts.AddOrUpdate((runId, type), 1, (_, current) => current + 1);
        return attempt == 1
            ? Task.FromException(new InvalidOperationException("Simulated first publish failure."))
            : Task.CompletedTask;
    }
}
