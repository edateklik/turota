# FastAPI Recommendation Entegrasyonu

## Akış

```text
JWT User
  → POST /api/recommendations/generate
  → Identity TasteProfile adapter
  → recommendation.recommendation_runs (Pending)
  → HTTP 202 Accepted + runId/statusUrl
  → Background Worker claim (FOR UPDATE SKIP LOCKED)
  → Processing → HTTP POST FastAPI content-based XAI modeli (1.5 saniye timeout)
  → Bölge + Mekanlar + Timeline + XAI
  → Aynı transaction: Run Completed/Failed + Outbox Pending
  → Outbox Dispatcher → SignalR → Outbox Processed
  → GET status sonucu
```

Recommendation modülü Identity veya Discovery tablolarına foreign key kurmaz. User,
Neighborhood ve Place kimlikleri modüller arası gevşek referanstır.

## .NET → FastAPI request

Varsayılan hedef: `POST http://localhost:8000/api/v1/recommendations/generate`

```json
{
  "request_id": "8ccf07b7-b327-451f-aab2-c781401fd900",
  "correlation_id": "0HNA...:00000001",
  "user_id": "6bde64a4-55ce-4c3a-8ed7-a896f24f224e",
  "trip_date": "2026-07-17",
  "available_minutes": 480,
  "start_location": {
    "longitude": 29.026,
    "latitude": 40.985
  },
  "taste_profile": {
    "preferred_category_ids": ["30000000-0000-0000-0000-000000000001"],
    "preferred_tag_ids": ["40000000-0000-0000-0000-000000000005"],
    "dietary_preferences": ["Vegan"],
    "budget_level": "Moderate",
    "travel_pace": "Balanced"
  }
}
```

`X-Correlation-ID` header'ı JSON içindeki `correlation_id` ile aynıdır.

## FastAPI → .NET response

```json
{
  "model_version": "local-discovery-v1",
  "region": {
    "neighborhood_id": "20000000-0000-0000-0000-000000000001",
    "name": "Caferağa",
    "score": 0.94,
    "explanation": "Kafe ve vegan tercihleriyle güçlü eşleşme."
  },
  "places": [
    {
      "place_id": "50000000-0000-0000-0000-000000000001",
      "name": "Moda Kahve Noktası",
      "score": 0.96,
      "explanation": "Kafe tercihiyle eşleşiyor."
    }
  ],
  "timeline": [
    {
      "sequence": 1,
      "place_id": "50000000-0000-0000-0000-000000000001",
      "place_name": "Moda Kahve Noktası",
      "start_time": "09:00:00",
      "duration_minutes": 60,
      "explanation": "Güne sakin bir başlangıç."
    }
  ],
  "overall_explanation": "TasteProfile ağırlıkları tüm sıralamada birlikte kullanıldı."
}
```

Skorlar `0-1`, mekan sayısı `1-100`, Timeline sayısı `1-50` aralığında olmalıdır.
Timeline toplam süresi kullanıcının `available_minutes` değerini aşamaz. Geçersiz sözleşme
PostgreSQL'e sonuç olarak yazılmaz; run `Failed / AI_INVALID_RESPONSE` olur.

## Persistence

```text
recommendation.recommendation_runs
recommendation.recommended_places
recommendation.timeline_items
recommendation.outbox_messages
```

Run önce giriş ve TasteProfile snapshot'ıyla `Pending` kaydedilir. Worker atomik olarak
`Processing` durumuna geçirir. Başarıda `Completed`; timeout, bağlantı veya sözleşme hatasında
üstel gecikmeyle en fazla üç kez denenip ilgili `failure_code` ile `Failed` olur. Worker
kapanırken iş tekrar `Pending` yapılır; süresi dolmuş `Processing` lease başka worker tarafından
geri alınabilir. Ham AI yanıtı saklanmaz; yalnız doğrulanmış alanlar kalıcılaştırılır.

Run terminal durumu ile `recommendation.completed.v1` veya `recommendation.failed.v1` outbox
mesajı aynı `SaveChanges` transaction'ında yazılır. Dispatcher mesajı `FOR UPDATE SKIP LOCKED`
ile claim eder, başarısız yayını üstel gecikmeyle tekrar dener ve başarıda `Processed` yapar.
Bu model at-least-once teslimat sağlar: dispatcher yayın sonrası fakat `Processed` kaydından önce
kapanırsa event tekrar gelebilir. React ve Flutter client'ları `runId` üzerinden idempotent
işlemeli ve sonucu REST durum endpoint'inden okuyabilmelidir. İşlenen outbox kayıtları varsayılan
olarak yedi gün sonra temizlenir; dead-letter `Failed` mesajları otomatik silinmez.

## REST endpointleri

```text
POST /api/recommendations/generate
GET  /api/recommendations/{runId}
GET  /api/recommendations/me/latest
```

Tümü JWT `User` policy gerektirir ve kullanıcı yalnızca kendi sonuçlarını okuyabilir.

`POST` başarılı kuyruklamada `202 Accepted` döndürür:

```json
{
  "runId": "8ccf07b7-b327-451f-aab2-c781401fd900",
  "status": "Pending",
  "statusUrl": "/api/recommendations/8ccf07b7-b327-451f-aab2-c781401fd900",
  "requestedAt": "2026-07-16T10:00:00+00:00"
}
```

Durum endpoint'i `Pending`, `Processing`, `Completed` veya `Failed` döndürür. `result` yalnız
`Completed` durumunda doludur; `Failed` durumunda `failureCode` client tarafından gösterilir.

## Standart hata yanıtı

Content-Type: `application/problem+json`

```json
{
  "type": "https://api.rota.local/errors/validation_error",
  "title": "İstek doğrulanamadı",
  "status": 400,
  "detail": "Kullanılabilir süre 60-720 dakika aralığında olmalıdır.",
  "instance": "/api/recommendations/generate",
  "errorCode": "VALIDATION_ERROR",
  "traceId": "00-...",
  "timestamp": "2026-07-16T10:00:00+00:00"
}
```

FastAPI kaynaklı hatalar HTTP isteği tamamlandıktan sonra worker içinde oluştuğu için problem
response değildir; durum endpoint'indeki `Failed/failureCode` alanları ve SignalR
`RecommendationFailed` eventiyle iletilir.

| Durum | HTTP | errorCode |
|---|---:|---|
| FastAPI timeout | Run `Failed` | `AI_SERVICE_TIMEOUT` |
| FastAPI bağlantı/5xx | Run `Failed` | `AI_SERVICE_UNAVAILABLE` |
| Geçersiz FastAPI JSON/sözleşme | Run `Failed` | `AI_INVALID_RESPONSE` |
| Request validation | 400 | `VALIDATION_ERROR` |
| JWT eksik/geçersiz | 401 | `UNAUTHORIZED` |
| Beklenmeyen hata | 500 | `INTERNAL_ERROR` |

## Yapılandırma

```json
{
  "FastApi": {
    "BaseUrl": "http://localhost:8000",
    "RecommendationPath": "/api/v1/recommendations/generate",
    "TimeoutMilliseconds": 1500
  },
  "RecommendationWorker": {
    "PollIntervalMilliseconds": 250,
    "LeaseSeconds": 30,
    "MaxAttempts": 3,
    "RetryDelayMilliseconds": 500
  },
  "OutboxWorker": {
    "PollIntervalMilliseconds": 250,
    "LeaseSeconds": 30,
    "MaxAttempts": 10,
    "RetryDelayMilliseconds": 500,
    "ProcessedRetentionHours": 168,
    "CleanupIntervalMinutes": 60
  }
}
```

Production'da `FastApi__BaseUrl` environment/secret configuration ile değiştirilmelidir.
Gerçek MVP servisi `ai-service` klasöründedir ve Discovery tablolarına salt-okunur erişimle
kategori, etiket, diyet, bütçe ve mesafe sinyallerini skorlar. Yerel hata senaryosu testi için
`tools/fastapi-contract-stub` kullanılabilir; stub öneri modeli değildir.
