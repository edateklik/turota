# Layered Modular Monolith Mimarisi

## Solution hiyerarşisi

```text
Rota.sln
├── src/
│   ├── Rota.Api/                                  # REST host, endpoint ve composition root
│   ├── BuildingBlocks/                            # Sonraki adımlar
│   │   ├── Rota.SharedKernel/                     # Entity, domain event, ortak sonuç tipleri
│   │   └── Rota.ServiceDefaults/                  # Logging, telemetry, hata standartları
│   └── Modules/
│       ├── Discovery/
│       │   ├── Rota.Modules.Discovery.Domain/     # Entity ve domain davranışları
│       │   ├── Rota.Modules.Discovery.Application/# Use-case, interface ve DTO sözleşmeleri
│       │   └── Rota.Modules.Discovery.Infrastructure/
│       │       ├── Admin/                         # Admin CRUD implementasyonları
│       │       ├── Features/                      # AI özellik vektörü üretimi
│       │       ├── Persistence/                   # DbContext, mapping, seed, migration
│       │       ├── Quality/                       # Veri kalite kontrolü
│       │       └── Spatial/                       # PostGIS repository
│       ├── Identity/                              # User, TasteProfile, JWT, roller
│       │   ├── Rota.Modules.Identity.Domain/
│       │   ├── Rota.Modules.Identity.Application/
│       │   └── Rota.Modules.Identity.Infrastructure/
│       ├── Trip/                                  # Timeline/günlük rota sınırı
│       ├── Recommendation/                        # FastAPI orchestration ve kalıcılık
│       │   ├── Rota.Modules.Recommendation.Domain/
│       │   ├── Rota.Modules.Recommendation.Application/
│       │   └── Rota.Modules.Recommendation.Infrastructure/
│       ├── Administration/                        # Admin use-case sınırı
│       └── Realtime/                              # SignalR sınırı
│           ├── Rota.Modules.Realtime.Application/ # Client event DTO/sözleşmeleri
│           └── Rota.Modules.Realtime.Infrastructure/ # Hub, JWT user mapping, publisher
└── tests/
    ├── Rota.Modules.Discovery.UnitTests/          # Sonraki: saf use-case testleri
    └── Rota.Api.IntegrationTests/                 # Sonraki: Testcontainers/PostGIS
```

## Bağımlılık yönü

```text
Rota.Api ──► Module.Application ──► Module.Domain
   │                 ▲
   └──► Module.Infrastructure ────► Module.Domain
```

- Domain; EF Core, HTTP veya dış servis bilmez.
- Application; use-case arayüzlerini, DTO'ları ve limit/koordinat kurallarını taşır.
- Infrastructure; EF Core, Npgsql, PostGIS, CRUD ve vektör kalıcılığını uygular.
- API yalnızca modül kaydı ve REST endpointlerini birleştirir.
- Modüller başka bir modülün `Infrastructure` katmanına doğrudan referans vermez.

Recommendation Application, altyapıdan bağımsız `IRecommendationEventPublisher` portunu
tanımlar. Realtime Infrastructure bu portu SignalR ile uygular; böylece Recommendation
modülü Hub veya WebSocket ayrıntılarını bilmez.

Recommendation üretimi HTTP request'ten ayrılmıştır. API `Pending` kaydı oluşturup `202`
döndürür; background worker PostgreSQL kuyruğunu `FOR UPDATE SKIP LOCKED` ile claim eder.
`Processing` lease süresi dolarsa iş tekrar alınabilir. Bu yapı tek veya birden fazla API
instance'ında aynı job'ın eşzamanlı işlenmesini engeller.

Recommendation sonucu ile entegrasyon eventi aynı PostgreSQL transaction'ında Outbox'a yazılır.
Ayrı dispatcher event'i SignalR publisher'a iletir ve ardından `Processed` işaretler. Böylece
DB commit sonrası process kapanması event kaybına yol açmaz. Teslimat at-least-once olduğu için
istemciler `runId` ile duplicate event'leri etkisizleştirir.

## Spatial sorgular

| Use-case | PostGIS işlemi | Index |
|---|---|---|
| Mahalle içindeki mekanlar | `ST_Covers(boundary, location)` | Mahalle `geometry` GiST |
| En yakın mekanlar | `ORDER BY location <-> point` + `ST_Distance(...::geography)` | Mekan `geometry` GiST/KNN |
| X km yarıçap | `ST_DWithin(location::geography, point::geography, metre)` | Fonksiyonel `geography` GiST |
| Yakındaki mahalleler | `boundary <-> point`, servis limiti `max 5` | Mahalle `geometry` GiST/KNN |

`geometry` tipi topolojik işlemleri ve KNN index sıralamasını sağlar. Kullanıcıya dönen
mesafe ve yarıçap filtresi `geography` üzerinden metre cinsinden hesaplanır. Böylece SRID
4326 üzerinde dereceyi kilometre gibi yorumlama hatası oluşmaz.

## Özellik vektörü v1

Vektör sırası kategori kimlikleri ve ardından etiket kimliklerinin deterministik sırasıdır:

```text
[category one-hot (6 boyut)] + [tag multi-hot (8 boyut)] = 14 boyut
```

Vektör L2 normalize edilir ve PostgreSQL `real[]` kolonunda saklanır. Boyutların anlamı
`GET /api/admin/places/feature-vectors/schema` ile okunabilir. Mekan oluşturma/güncelleme
işlemi vektörü otomatik üretir; toplu yeniden üretim için rebuild endpointi bulunur.

Kategori veya etiket taksonomisi değiştiğinde `CurrentVersion` artırılmalı ve toplu rebuild
çalıştırılmalıdır. İleride pgvector/cosine similarity eklenirken bu sözleşme korunabilir.
