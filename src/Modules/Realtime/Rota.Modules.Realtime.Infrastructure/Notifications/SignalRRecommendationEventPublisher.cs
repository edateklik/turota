using Microsoft.AspNetCore.SignalR;
using Rota.Modules.Realtime.Application.Contracts;
using Rota.Modules.Realtime.Infrastructure.Hubs;
using Rota.Modules.Recommendation.Application.Contracts;

namespace Rota.Modules.Realtime.Infrastructure.Notifications;

public sealed class SignalRRecommendationEventPublisher(
    IHubContext<NotificationHub, INotificationClient> hubContext) : IRecommendationEventPublisher
{
    public async Task PublishCompletedAsync(
        RecommendationCompletedEvent notification,
        CancellationToken cancellationToken = default)
    {
        await hubContext.Clients.User(notification.UserId.ToString()).RecommendationCompleted(
            new RecommendationCompletedNotification(
                notification.RunId,
                notification.TripDate,
                notification.NeighborhoodId,
                notification.RegionName,
                notification.CompletedAt));
    }

    public async Task PublishFailedAsync(
        RecommendationFailedEvent notification,
        CancellationToken cancellationToken = default)
    {
        await hubContext.Clients.User(notification.UserId.ToString()).RecommendationFailed(
            new RecommendationFailedNotification(
                notification.RunId,
                notification.TripDate,
                notification.ErrorCode,
                notification.FailedAt));
    }
}
