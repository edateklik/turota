using System.Net.Http.Json;
using System.Net.WebSockets;
using System.Text;
using System.Text.Json;

if (args.Length is < 2 or > 3)
{
    Console.Error.WriteLine("Usage: Rota.SignalR.SmokeClient <api-base-url> <jwt> [timeout-seconds]");
    return 64;
}

var apiBaseUrl = args[0].TrimEnd('/');
var accessToken = args[1];
var timeoutSeconds = args.Length == 3 && int.TryParse(args[2], out var parsed) ? parsed : 15;
using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(timeoutSeconds));

using var httpClient = new HttpClient();
var negotiateUrl = $"{apiBaseUrl}/hubs/notification/negotiate?negotiateVersion=1&access_token={Uri.EscapeDataString(accessToken)}";
using var negotiateResponse = await httpClient.PostAsync(negotiateUrl, null, timeout.Token);
negotiateResponse.EnsureSuccessStatusCode();
var negotiation = await negotiateResponse.Content.ReadFromJsonAsync<Negotiation>(cancellationToken: timeout.Token)
    ?? throw new InvalidOperationException("SignalR negotiate yanıtı okunamadı.");

var webSocketBaseUrl = apiBaseUrl.StartsWith("https://", StringComparison.OrdinalIgnoreCase)
    ? $"wss://{apiBaseUrl[8..]}"
    : $"ws://{apiBaseUrl[7..]}";
var socketUrl = $"{webSocketBaseUrl}/hubs/notification?id={Uri.EscapeDataString(negotiation.ConnectionToken)}&access_token={Uri.EscapeDataString(accessToken)}";

using var socket = new ClientWebSocket();
await socket.ConnectAsync(new Uri(socketUrl), timeout.Token);
await SendAsync(socket, "{\"protocol\":\"json\",\"version\":1}\u001e", timeout.Token);

try
{
    while (!timeout.IsCancellationRequested)
    {
        var message = await ReceiveAsync(socket, timeout.Token);
        foreach (var frame in message.Split('\u001e', StringSplitOptions.RemoveEmptyEntries))
        {
            using var document = JsonDocument.Parse(frame);
            if (!document.RootElement.TryGetProperty("target", out var target)) continue;
            Console.WriteLine(JsonSerializer.Serialize(new
            {
                target = target.GetString(),
                arguments = document.RootElement.GetProperty("arguments")
            }));
            return 0;
        }
    }
}
catch (OperationCanceledException) when (timeout.IsCancellationRequested)
{
    Console.Error.WriteLine("Bildirim bekleme süresi doldu.");
    return 2;
}

return 2;

static async Task SendAsync(ClientWebSocket socket, string value, CancellationToken cancellationToken)
{
    var payload = Encoding.UTF8.GetBytes(value);
    await socket.SendAsync(payload, WebSocketMessageType.Text, true, cancellationToken);
}

static async Task<string> ReceiveAsync(ClientWebSocket socket, CancellationToken cancellationToken)
{
    var buffer = new byte[8 * 1024];
    using var stream = new MemoryStream();
    WebSocketReceiveResult result;
    do
    {
        result = await socket.ReceiveAsync(buffer, cancellationToken);
        if (result.MessageType == WebSocketMessageType.Close)
            throw new WebSocketException("SignalR bağlantısı event alınmadan kapandı.");
        stream.Write(buffer, 0, result.Count);
    } while (!result.EndOfMessage);

    return Encoding.UTF8.GetString(stream.ToArray());
}

internal sealed record Negotiation(string ConnectionToken);
