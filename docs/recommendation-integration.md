# FastAPI Recommendation Entegrasyonu

## Akış

```text
JWT User
  → POST /api/recommendations/generate
  → Identity TasteProfile adapter
  → recommendation.recommendation_runs (Pending)
  → HTTP POST FastAPI (1.5 saniye timeout)
  → Bölge + Mekanlar + Timeline + XAI
  → PostgreSQL (Completed veya Failed)
  → RecommendationResponse
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
```

Run önce `Pending` kaydedilir. Başarıda `Completed`; timeout, bağlantı veya sözleşme
hatasında ilgili `failure_code` ile `Failed` olur. Ham AI yanıtı saklanmaz; sadece doğrulanmış,
frontend sözleşmesinde kullanılan alanlar kalıcılaştırılır.

## REST endpointleri

```text
POST /api/recommendations/generate
GET  /api/recommendations/{runId}
GET  /api/recommendations/me/latest
```

Tümü JWT `User` policy gerektirir ve kullanıcı yalnızca kendi sonuçlarını okuyabilir.

## Standart hata yanıtı

Content-Type: `application/problem+json`

```json
{
  "type": "https://api.rota.local/errors/ai_service_timeout",
  "title": "AI servisi zaman aşımı",
  "status": 504,
  "detail": "AI öneri servisi zaman aşımına uğradı.",
  "instance": "/api/recommendations/generate",
  "errorCode": "AI_SERVICE_TIMEOUT",
  "traceId": "00-...",
  "timestamp": "2026-07-16T10:00:00+00:00"
}
```

| Durum | HTTP | errorCode |
|---|---:|---|
| FastAPI timeout | 504 | `AI_SERVICE_TIMEOUT` |
| FastAPI bağlantı/5xx | 503 | `AI_SERVICE_UNAVAILABLE` |
| Geçersiz FastAPI JSON/sözleşme | 502 | `AI_INVALID_RESPONSE` |
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
  }
}
```

Production'da `FastApi__BaseUrl` environment/secret configuration ile değiştirilmelidir.
Yerel sözleşme testi için `tools/fastapi-contract-stub` kullanılabilir; bu araç AI modeli değildir.
