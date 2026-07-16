using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using Rota.Modules.Realtime.Infrastructure.Hubs;
using Rota.Modules.Realtime.Infrastructure.Notifications;
using Rota.Modules.Realtime.Infrastructure.Security;
using Rota.Modules.Recommendation.Application.Contracts;

namespace Rota.Modules.Realtime.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddRealtimeInfrastructure(this IServiceCollection services)
    {
        services.AddSignalR(options =>
        {
            options.EnableDetailedErrors = false;
            options.MaximumReceiveMessageSize = 32 * 1_024;
            options.ClientTimeoutInterval = TimeSpan.FromSeconds(30);
            options.KeepAliveInterval = TimeSpan.FromSeconds(15);
        });
        services.AddSingleton<IUserIdProvider, SubClaimUserIdProvider>();
        services.AddSingleton<IRecommendationEventHandler, SignalRRecommendationEventPublisher>();
        services.AddSingleton<IPostConfigureOptions<JwtBearerOptions>, SignalRJwtBearerPostConfigure>();
        return services;
    }

    private sealed class SignalRJwtBearerPostConfigure : IPostConfigureOptions<JwtBearerOptions>
    {
        public void PostConfigure(string? name, JwtBearerOptions options)
        {
            if (name != JwtBearerDefaults.AuthenticationScheme) return;

            options.Events ??= new JwtBearerEvents();
            var previousHandler = options.Events.OnMessageReceived;
            options.Events.OnMessageReceived = async context =>
            {
                if (previousHandler is not null) await previousHandler(context);
                if (!string.IsNullOrEmpty(context.Token)) return;

                var accessToken = context.Request.Query["access_token"];
                if (!string.IsNullOrEmpty(accessToken) &&
                    context.HttpContext.Request.Path.StartsWithSegments(NotificationHub.Route))
                    context.Token = accessToken;
            };
        }
    }
}
