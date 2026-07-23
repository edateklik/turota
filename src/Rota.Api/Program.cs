using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using System.Text.Json.Serialization;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.FileProviders;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using Rota.Modules.Discovery.Infrastructure;
using Rota.Modules.Discovery.Infrastructure.Persistence;
using Rota.Modules.Discovery.Infrastructure.Quality;
using Rota.Api.Endpoints;
using Rota.Api.Errors;
using Rota.Modules.Identity.Infrastructure;
using Rota.Modules.Identity.Infrastructure.Persistence;
using Rota.Modules.Identity.Infrastructure.Services;
using Rota.Api.OpenApi;
using Rota.Api.Security;
using Rota.Modules.Recommendation.Infrastructure;
using Rota.Modules.Recommendation.Infrastructure.Persistence;
using Rota.Modules.Realtime.Infrastructure;
using Rota.Modules.Realtime.Infrastructure.Hubs;
using Rota.Modules.Trip.Infrastructure;
using Rota.Modules.Trip.Infrastructure.Persistence;
using Rota.Modules.Administration.Infrastructure;
using Rota.Api.Observability;

var builder = WebApplication.CreateBuilder(args);
var rateLimits = builder.Configuration.GetSection("RateLimits").Get<RateLimitOptions>() ?? new RateLimitOptions();
rateLimits.Validate();
var rateLimitWindow = TimeSpan.FromSeconds(rateLimits.WindowSeconds);

if (builder.Configuration.GetValue<bool>("Observability:UseJsonConsole"))
{
    builder.Logging.ClearProviders();
    builder.Logging.AddJsonConsole();
}

var otlpEnabled = builder.Configuration.GetValue<bool>("Observability:OtlpEnabled");
builder.Services.AddOpenTelemetry()
    .ConfigureResource(resource => resource.AddService(
        serviceName: builder.Configuration["Observability:ServiceName"] ?? "rota-api",
        serviceVersion: typeof(Program).Assembly.GetName().Version?.ToString()))
    .WithTracing(tracing =>
    {
        tracing
            .AddAspNetCoreInstrumentation(options => options.Filter = context => !context.Request.Path.StartsWithSegments("/health"))
            .AddHttpClientInstrumentation();
        if (otlpEnabled) tracing.AddOtlpExporter();
    })
    .WithMetrics(metrics =>
    {
        metrics
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation()
            .AddRuntimeInstrumentation();
        if (otlpEnabled) metrics.AddOtlpExporter();
    });

builder.Services.AddDiscoveryInfrastructure(builder.Configuration);
builder.Services.AddIdentityInfrastructure(builder.Configuration);
builder.Services.AddRecommendationInfrastructure(builder.Configuration);
builder.Services.AddTripInfrastructure(builder.Configuration);
builder.Services.AddAdministrationInfrastructure(builder.Configuration);
builder.Services.AddRealtimeInfrastructure();
var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
builder.Services.AddCors(options => options.AddPolicy("Frontend", policy =>
{
    if (allowedOrigins.Length > 0)
        policy.WithOrigins(allowedOrigins).AllowAnyHeader().AllowAnyMethod().AllowCredentials();
}));
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
        RateLimitPartition.GetFixedWindowLimiter(
            context.User.FindFirst("sub")?.Value
            ?? context.Connection.RemoteIpAddress?.ToString()
            ?? "anonymous",
            _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = rateLimits.GlobalPermitLimit,
                Window = rateLimitWindow,
                QueueLimit = 0,
                AutoReplenishment = true
            }));
    options.AddFixedWindowLimiter("authentication", limiter =>
    {
        limiter.PermitLimit = rateLimits.AuthenticationPermitLimit;
        limiter.Window = rateLimitWindow;
        limiter.QueueLimit = 0;
        limiter.AutoReplenishment = true;
    });
    options.AddFixedWindowLimiter("recommendation", limiter =>
    {
        limiter.PermitLimit = rateLimits.RecommendationPermitLimit;
        limiter.Window = rateLimitWindow;
        limiter.QueueLimit = 0;
        limiter.AutoReplenishment = true;
    });
    options.AddFixedWindowLimiter("admin-simulation", limiter =>
    {
        limiter.PermitLimit = rateLimits.AdminSimulationPermitLimit;
        limiter.Window = rateLimitWindow;
        limiter.QueueLimit = 0;
        limiter.AutoReplenishment = true;
    });
});
builder.Services.AddHttpClient(FastApiReadinessHealthCheck.HttpClientName, client =>
{
    client.BaseAddress = new Uri(builder.Configuration["FastApi:BaseUrl"]
        ?? throw new InvalidOperationException("FastApi:BaseUrl yapılandırılmalıdır."));
    client.Timeout = TimeSpan.FromMilliseconds(750);
});
builder.Services.AddHealthChecks()
    .AddCheck<PostgresReadinessHealthCheck>("postgres", tags: ["ready"])
    .AddCheck<FastApiReadinessHealthCheck>("fastapi", tags: ["ready"]);
builder.Services.AddProblemDetails();
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.ConfigureHttpJsonOptions(options =>
    options.SerializerOptions.Converters.Add(new JsonStringEnumConverter()));
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Rota Local Discovery API",
        Version = "v1",
        Description = "React, Flutter ve AI servisleri için Identity, Discovery ve Administration REST sözleşmeleri."
    });
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Login/Register yanıtındaki accessToken değerini girin."
    });
    options.OperationFilter<AuthorizeCheckOperationFilter>();
    var xmlPath = Path.Combine(AppContext.BaseDirectory, "Rota.Api.xml");
    if (File.Exists(xmlPath)) options.IncludeXmlComments(xmlPath);
    var identityXmlPath = Path.Combine(AppContext.BaseDirectory, "Rota.Modules.Identity.Application.xml");
    if (File.Exists(identityXmlPath)) options.IncludeXmlComments(identityXmlPath);
    var recommendationXmlPath = Path.Combine(AppContext.BaseDirectory, "Rota.Modules.Recommendation.Application.xml");
    if (File.Exists(recommendationXmlPath)) options.IncludeXmlComments(recommendationXmlPath);
    var tripXmlPath = Path.Combine(AppContext.BaseDirectory, "Rota.Modules.Trip.Application.xml");
    if (File.Exists(tripXmlPath)) options.IncludeXmlComments(tripXmlPath);
    var administrationXmlPath = Path.Combine(AppContext.BaseDirectory, "Rota.Modules.Administration.Application.xml");
    if (File.Exists(administrationXmlPath)) options.IncludeXmlComments(administrationXmlPath);
});

var app = builder.Build();
var profilePhotoOptions = app.Services.GetRequiredService<ProfilePhotoStorageOptions>();
Directory.CreateDirectory(profilePhotoOptions.RootPath);
app.UseMiddleware<RequestTelemetryMiddleware>();
app.UseExceptionHandler();
app.UseStatusCodePages(async statusCodeContext =>
{
    var httpContext = statusCodeContext.HttpContext;
    var (title, code) = httpContext.Response.StatusCode switch
    {
        StatusCodes.Status401Unauthorized => ("Kimlik doğrulama gerekli", "UNAUTHORIZED"),
        StatusCodes.Status403Forbidden => ("Bu işlem için yetkiniz yok", "FORBIDDEN"),
        StatusCodes.Status404NotFound => ("Kaynak bulunamadı", "ROUTE_NOT_FOUND"),
        StatusCodes.Status429TooManyRequests => ("Çok fazla istek gönderildi", "RATE_LIMIT_EXCEEDED"),
        _ => ("İstek tamamlanamadı", "HTTP_ERROR")
    };
    var problem = new ApiProblemDetails
    {
        Type = $"https://api.rota.local/errors/{code.ToLowerInvariant()}",
        Title = title,
        Status = httpContext.Response.StatusCode,
        Instance = httpContext.Request.Path,
        ErrorCode = code,
        TraceId = httpContext.TraceIdentifier,
        Timestamp = TimeProvider.System.GetUtcNow()
    };
    await httpContext.RequestServices.GetRequiredService<IProblemDetailsService>()
        .WriteAsync(new ProblemDetailsContext { HttpContext = httpContext, ProblemDetails = problem });
});

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "Rota API v1");
        options.DocumentTitle = "Rota API Documentation";
        options.DisplayRequestDuration();
        options.EnableTryItOutByDefault();
    });
}

if (app.Configuration.GetValue<bool>("Database:ApplyMigrationsOnStartup"))
{
    await using var scope = app.Services.CreateAsyncScope();
    await scope.ServiceProvider.GetRequiredService<DiscoveryDbContext>().Database.MigrateAsync();
    await scope.ServiceProvider.GetRequiredService<IdentityDbContext>().Database.MigrateAsync();
    await scope.ServiceProvider.GetRequiredService<RecommendationDbContext>().Database.MigrateAsync();
    await scope.ServiceProvider.GetRequiredService<TripDbContext>().Database.MigrateAsync();
}

app.UseCors("Frontend");
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(profilePhotoOptions.RootPath),
    RequestPath = profilePhotoOptions.RequestPath
});
app.UseAuthentication();
app.UseRateLimiter();
app.UseAuthorization();
app.MapGet("/api/discovery/data-quality", async (
    DiscoveryDataQualityService qualityService,
    CancellationToken cancellationToken) =>
{
    var report = await qualityService.CheckAsync(cancellationToken);
    return report.IsHealthy ? Results.Ok(report) : Results.Json(report, statusCode: StatusCodes.Status503ServiceUnavailable);
});

app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = _ => false,
    ResponseWriter = HealthResponseWriter.WriteAsync
}).DisableRateLimiting();
app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready"),
    ResponseWriter = HealthResponseWriter.WriteAsync
}).DisableRateLimiting();
app.MapHealthChecks("/health", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready"),
    ResponseWriter = HealthResponseWriter.WriteAsync
}).DisableRateLimiting();
app.MapDiscoveryEndpoints();
app.MapIdentityEndpoints();
app.MapRecommendationEndpoints();
app.MapTripEndpoints();
app.MapAdministrationEndpoints();
app.MapHub<NotificationHub>(NotificationHub.Route).RequireAuthorization("User");
app.Run();

public partial class Program;
