using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using Rota.Modules.Identity.Application.Contracts;
using Rota.Modules.Identity.Domain.Entities;
using Rota.Modules.Identity.Infrastructure.Persistence;
using Rota.Modules.Identity.Infrastructure.Security;
using Rota.Modules.Identity.Infrastructure.Services;

namespace Rota.Modules.Identity.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddIdentityInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("IdentityDb")
            ?? throw new InvalidOperationException("ConnectionStrings:IdentityDb yapılandırılmalıdır.");
        var jwtOptions = configuration.GetRequiredSection(JwtOptions.SectionName).Get<JwtOptions>()
            ?? throw new InvalidOperationException("Jwt yapılandırması bulunamadı.");
        ValidateJwtOptions(jwtOptions);

        services.AddOptions<JwtOptions>()
            .Bind(configuration.GetRequiredSection(JwtOptions.SectionName))
            .Validate(options => options.SigningKey.Length >= 32, "JWT signing key en az 32 karakter olmalıdır.")
            .Validate(options => options.ExpirationMinutes is >= 5 and <= 1_440, "JWT süresi 5-1440 dakika aralığında olmalıdır.")
            .ValidateOnStart();
        services.AddDbContextPool<IdentityDbContext>(options =>
            options.UseNpgsql(connectionString, npgsql =>
            {
                npgsql.MigrationsHistoryTable("__ef_migrations_history", "identity");
                npgsql.EnableRetryOnFailure(3);
                npgsql.CommandTimeout(2);
            }));
        services.AddSingleton(TimeProvider.System);
        services.AddScoped<IPasswordHasher<User>, PasswordHasher<User>>();
        services.AddScoped<IJwtTokenService, JwtTokenService>();
        services.AddScoped<IIdentityService, IdentityService>();

        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.MapInboundClaims = false;
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = jwtOptions.Issuer,
                    ValidateAudience = true,
                    ValidAudience = jwtOptions.Audience,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtOptions.SigningKey)),
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.FromSeconds(30),
                    NameClaimType = "name",
                    RoleClaimType = "role"
                };
            });
        services.AddAuthorization(options =>
        {
            options.AddPolicy("Admin", policy => policy
                .RequireAuthenticatedUser()
                .RequireClaim("role", UserRole.Admin.ToString()));
            options.AddPolicy("User", policy => policy.RequireAuthenticatedUser());
        });

        return services;
    }

    private static void ValidateJwtOptions(JwtOptions options)
    {
        if (string.IsNullOrWhiteSpace(options.Issuer) || string.IsNullOrWhiteSpace(options.Audience))
            throw new InvalidOperationException("JWT issuer ve audience boş olamaz.");
        if (string.IsNullOrWhiteSpace(options.SigningKey) || Encoding.UTF8.GetByteCount(options.SigningKey) < 32)
            throw new InvalidOperationException("JWT signing key en az 32 byte olmalı ve secret/environment üzerinden sağlanmalıdır.");
        if (options.ExpirationMinutes is < 5 or > 1_440)
            throw new InvalidOperationException("JWT süresi 5-1440 dakika aralığında olmalıdır.");
    }
}
