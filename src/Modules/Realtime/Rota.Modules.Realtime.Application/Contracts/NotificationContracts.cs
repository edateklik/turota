namespace Rota.Modules.Realtime.Application.Contracts;

public sealed record RecommendationCompletedNotification(
    Guid RunId,
    DateOnly TripDate,
    Guid NeighborhoodId,
    string RegionName,
    DateTimeOffset CompletedAt);

public sealed record RecommendationFailedNotification(
    Guid RunId,
    DateOnly TripDate,
    string ErrorCode,
    DateTimeOffset FailedAt);

public sealed record SystemNotification(string Code, string Message, DateTimeOffset CreatedAt);

/// <summary>React ve Flutter SignalR client event sözleşmesi.</summary>
public interface INotificationClient
{
    Task RecommendationCompleted(RecommendationCompletedNotification notification);
    Task RecommendationFailed(RecommendationFailedNotification notification);
    Task NotificationReceived(SystemNotification notification);
}
