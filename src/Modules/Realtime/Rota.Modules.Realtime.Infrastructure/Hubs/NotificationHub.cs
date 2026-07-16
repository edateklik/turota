using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Rota.Modules.Realtime.Application.Contracts;

namespace Rota.Modules.Realtime.Infrastructure.Hubs;

[Authorize(Policy = "User")]
public sealed class NotificationHub : Hub<INotificationClient>
{
    public const string Route = "/hubs/notification";
}
