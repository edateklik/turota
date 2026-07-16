# SignalR Realtime sözleşmesi

## Endpoint ve kimlik

- Hub: `/hubs/notification`
- Yetkilendirme: JWT Bearer, `User` policy
- Kullanıcı anahtarı: doğrulanmış JWT içindeki `sub` claim'i
- Hedefleme: `Clients.User(userId)`; aynı kullanıcının web ve mobil bağlantıları event'i alır
- Transport: WebSockets, Server-Sent Events veya Long Polling (SignalR negotiation seçer)

Tarayıcı WebSocket ve SSE API'leri özel `Authorization` header'ı ayarlayamadığından SignalR
client erişim token'ını bu taşımalarda `access_token` query parametresiyle iletebilir. API bu
parametreyi yalnız `/hubs/notification` yolu için kabul eder. Production'da HTTPS/WSS zorunlu
olmalı ve reverse proxy access log'larında query string/token redakte edilmelidir.

Frontend origin'leri `Cors:AllowedOrigins` altında açıkça listelenir. Credential kullanılan
SignalR bağlantıları nedeniyle wildcard origin kullanılmaz.

## Server event'leri

### `RecommendationCompleted`

```json
{
  "runId": "6fcfeba3-ae64-45b4-8e85-0d5ef230e8a0",
  "tripDate": "2026-07-17",
  "neighborhoodId": "20000000-0000-0000-0000-000000000001",
  "regionName": "Caferağa",
  "completedAt": "2026-07-16T08:14:27.476026+00:00"
}
```

### `RecommendationFailed`

```json
{
  "runId": "6fcfeba3-ae64-45b4-8e85-0d5ef230e8a0",
  "tripDate": "2026-07-17",
  "errorCode": "AI_SERVICE_UNAVAILABLE",
  "failedAt": "2026-07-16T08:14:27.476026+00:00"
}
```

Event, öneri sonucu PostgreSQL'e kaydedildikten sonra yayınlanır. Bildirim transport'undaki
geçici hata kayıtlı öneriyi geri almaz; reconnect sonrası client sonucu
`GET /api/recommendations/me/latest` veya run kimliğiyle tekrar okuyabilir.

## React bağlantısı

```ts
import * as signalR from "@microsoft/signalr";

const connection = new signalR.HubConnectionBuilder()
  .withUrl(`${apiBaseUrl}/hubs/notification`, {
    accessTokenFactory: () => accessToken,
  })
  .withAutomaticReconnect()
  .build();

connection.on("RecommendationCompleted", payload => {
  // payload.runId ile sonucu REST API'den aç.
});

connection.on("RecommendationFailed", payload => {
  // payload.errorCode değerini kullanıcı dostu mesaja eşle.
});

await connection.start();
```

Flutter tarafında kullanılan SignalR paketinin token callback/HTTP options alanına aynı JWT,
hub URL alanına `/hubs/notification` verilir ve yukarıdaki iki event adı birebir dinlenir.
Paket seçimi değişse de wire sözleşmesi bu dokümandaki event adları ve JSON payload'lardır.

## Yerel smoke testi

Repo içindeki bağımsız araç negotiate + WebSocket handshake yapar ve ilk server event'ini
JSON olarak yazar:

```bash
dotnet run --project tools/Rota.SignalR.SmokeClient -- \
  http://localhost:5121 "$ACCESS_TOKEN" 15
```

Anonim kontrol:

```bash
curl -i -X POST \
  'http://localhost:5121/hubs/notification/negotiate?negotiateVersion=1'
```

Beklenen yanıt `401 application/problem+json` biçimindedir.
