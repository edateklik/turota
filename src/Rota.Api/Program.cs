using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using System.Text.Json.Serialization;
using Rota.Modules.Discovery.Infrastructure;
using Rota.Modules.Discovery.Infrastructure.Persistence;
using Rota.Modules.Discovery.Infrastructure.Quality;
using Rota.Api.Endpoints;
using Rota.Api.Errors;
using Rota.Modules.Identity.Infrastructure;
using Rota.Modules.Identity.Infrastructure.Persistence;
using Rota.Api.OpenApi;
using Rota.Modules.Recommendation.Infrastructure;
using Rota.Modules.Recommendation.Infrastructure.Persistence;
using Rota.Modules.Realtime.Infrastructure;
using Rota.Modules.Realtime.Infrastructure.Hubs;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDiscoveryInfrastructure(builder.Configuration);
builder.Services.AddIdentityInfrastructure(builder.Configuration);
builder.Services.AddRecommendationInfrastructure(builder.Configuration);
builder.Services.AddRealtimeInfrastructure();
var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
builder.Services.AddCors(options => options.AddPolicy("Frontend", policy =>
{
    if (allowedOrigins.Length > 0)
        policy.WithOrigins(allowedOrigins).AllowAnyHeader().AllowAnyMethod().AllowCredentials();
}));
builder.Services.AddHealthChecks();
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
});

var app = builder.Build();
app.UseExceptionHandler();
app.UseStatusCodePages(async statusCodeContext =>
{
    var httpContext = statusCodeContext.HttpContext;
    var (title, code) = httpContext.Response.StatusCode switch
    {
        StatusCodes.Status401Unauthorized => ("Kimlik doğrulama gerekli", "UNAUTHORIZED"),
        StatusCodes.Status403Forbidden => ("Bu işlem için yetkiniz yok", "FORBIDDEN"),
        StatusCodes.Status404NotFound => ("Kaynak bulunamadı", "ROUTE_NOT_FOUND"),
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
}

app.UseCors("Frontend");
app.UseAuthentication();
app.UseAuthorization();
app.MapGet("/api/discovery/data-quality", async (
    DiscoveryDataQualityService qualityService,
    CancellationToken cancellationToken) =>
{
    var report = await qualityService.CheckAsync(cancellationToken);
    return report.IsHealthy ? Results.Ok(report) : Results.Json(report, statusCode: StatusCodes.Status503ServiceUnavailable);
});

app.MapHealthChecks("/health");
app.MapDiscoveryEndpoints();
app.MapIdentityEndpoints();
app.MapRecommendationEndpoints();
app.MapHub<NotificationHub>(NotificationHub.Route).RequireAuthorization("User");
app.Run();

public partial class Program;
