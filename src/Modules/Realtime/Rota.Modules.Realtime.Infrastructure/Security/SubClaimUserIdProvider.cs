using Microsoft.AspNetCore.SignalR;

namespace Rota.Modules.Realtime.Infrastructure.Security;

public sealed class SubClaimUserIdProvider : IUserIdProvider
{
    public string? GetUserId(HubConnectionContext connection) =>
        connection.User?.FindFirst("sub")?.Value;
}
