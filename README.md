# Rota — AI Destekli Local Discovery Platform

ASP.NET Core 8 ve PostgreSQL/PostGIS tabanlı layered modular monolith başlangıç yapısı.
`Discovery`; şehir, mahalle, mekan, kategori ve etiket verisini, `Identity`; User,
TasteProfile ve JWT akışını, `Recommendation`; FastAPI orchestration'ını, `Realtime` ise
kullanıcıya özel SignalR bildirimlerini yönetir.

## Mimari

```text
src/
├── Rota.Api/                    # REST + SignalR host / composition root
└── Modules/
    ├── Discovery/               # PostGIS, spatial query, admin CRUD
    ├── Identity/                # User, TasteProfile, JWT ve roller
    ├── Recommendation/          # FastAPI client, orchestration, persistence
    └── Realtime/                # SignalR hub ve event publisher
```

Ayrıntılı hedef solution yapısı ve bağımlılık kuralları için
[`docs/architecture.md`](docs/architecture.md) dosyasına bakın.
Identity/frontend sözleşmesi için [`docs/identity.md`](docs/identity.md) dosyasına bakın.
FastAPI sözleşmesi ve hata matrisi için
[`docs/recommendation-integration.md`](docs/recommendation-integration.md) dosyasına bakın.
SignalR event sözleşmesi ve frontend bağlantı örneği için
[`docs/realtime.md`](docs/realtime.md) dosyasına bakın.

Veritabanı nesneleri modül izolasyonu için `discovery` şemasındadır. Mahalle sınırı
`geometry(MultiPolygon,4326)`, mekan konumu `geometry(Point,4326)` olarak tutulur.
Her iki spatial kolon üzerinde GiST index vardır.

## Kullanılan NuGet paketleri

- `Npgsql.EntityFrameworkCore.PostgreSQL` 8.0.8
- `Npgsql.EntityFrameworkCore.PostgreSQL.NetTopologySuite` 8.0.8
- `NetTopologySuite` 2.6.0
- `Microsoft.EntityFrameworkCore.Design` 8.0.8
- `Microsoft.AspNetCore.Authentication.JwtBearer` 8.0.28
- `Swashbuckle.AspNetCore` 6.6.2

Sürümler `Directory.Packages.props` içinde merkezi olarak yönetilir.

## Çalıştırma

Gereksinimler: .NET SDK 8, Docker Desktop/Engine.

```bash
docker compose up -d --wait
dotnet tool restore
dotnet restore
dotnet ef database update \
  --project src/Modules/Discovery/Rota.Modules.Discovery.Infrastructure \
  --context DiscoveryDbContext
dotnet run --project src/Rota.Api
```

Development profilinde Swagger UI `http://localhost:5121/swagger` adresindedir.

Development profilinde API başlarken migration otomatik uygulanır. Production için
`Database:ApplyMigrationsOnStartup=false` bırakılmalı ve migration deployment
pipeline'ında uygulanmalıdır. Bağlantı bilgisi secret/environment ile ezilebilir:

```bash
export ConnectionStrings__DiscoveryDb='Host=localhost;Port=5432;Database=rota;Username=rota;Password=...'
export ConnectionStrings__IdentityDb="$ConnectionStrings__DiscoveryDb"
export ConnectionStrings__RecommendationDb="$ConnectionStrings__DiscoveryDb"
export Jwt__SigningKey='en-az-32-byte-guvenli-secret'
export FastApi__BaseUrl='http://localhost:8000'
export Cors__AllowedOrigins__0='https://app.example.com'
```

Yeni migration oluşturma:

```bash
dotnet ef migrations add MigrationAdi \
  --project src/Modules/Discovery/Rota.Modules.Discovery.Infrastructure \
  --context DiscoveryDbContext \
  --output-dir Persistence/Migrations
```

## Seed veri ve doğrulama

Initial migration deterministik kimliklerle 1 şehir, 3 mahalle, 36 mekan, 6 kategori,
8 etiket ve mekan-etiket ilişkilerini ekler. Seed hazırlanırken aşağıdakiler model
oluşturma aşamasında doğrulanır:

- Mahalle sayısı en az 3 ve mekan sayısı 30-50 aralığında.
- Geometriler dolu, geçerli ve SRID 4326.
- Her mekan noktası bağlı olduğu mahalle poligonu içinde.
- Mekan kimlikleri benzersiz ve kategori ilişkileri geçerli.

Çalışan veritabanını REST üzerinden doğrulamak için:

```bash
curl http://localhost:5000/api/discovery/data-quality
```

Sağlıklı seed için `isHealthy: true`, `neighborhoodCount: 3`, `placeCount: 36` ve
üç hata sayacının da `0` olması beklenir. Doğrulama başarısızsa endpoint HTTP 503 döner.

## Spatial REST API

```text
GET /api/discovery/neighborhoods/{id}/places
GET /api/discovery/places/nearest?longitude=29.026&latitude=40.985&limit=20
GET /api/discovery/places/within-radius?longitude=29.026&latitude=40.985&radiusKilometers=1
GET /api/discovery/neighborhoods/nearby?longitude=29.026&latitude=40.985&limit=5
```

Mekan sonuçları en fazla 100, çevredeki mahalleler en fazla 5 kayıtla sınırlandırılır.
Yarıçap en fazla 50 km olabilir. Mesafeler yanıtta metre olarak döner.

Admin CRUD kaynakları `/api/admin/cities`, `/api/admin/neighborhoods`,
`/api/admin/places`, `/api/admin/categories` ve `/api/admin/tags` altındadır.
Özellik vektörü endpointleri:

```text
GET  /api/admin/places/{id}/feature-vector
GET  /api/admin/places/feature-vectors/schema
POST /api/admin/places/{id}/feature-vector/rebuild
POST /api/admin/places/feature-vectors/rebuild
```

Admin endpointleri JWT `Admin` policy ile korunur.

## Realtime

JWT korumalı hub endpoint'i `GET/POST /hubs/notification` yolundadır. Öneri işlemi
tamamlandığında `RecommendationCompleted`, başarısız olduğunda `RecommendationFailed`
event'i yalnız JWT `sub` değerindeki kullanıcıya gönderilir. SignalR endpoint'leri Swagger'a
girmediği için taşıma ve payload sözleşmeleri `docs/realtime.md` içinde tutulur.

## Asenkron öneri akışı

`POST /api/recommendations/generate` FastAPI sonucunu beklemez; kalıcı job kaydı oluşturup
`202 Accepted`, `runId` ve `statusUrl` döndürür. PostgreSQL tabanlı worker işi claim eder,
başarısız dış servis çağrılarını en fazla üç kez yeniden dener ve sonucu SignalR ile bildirir.
Client aynı zamanda `GET /api/recommendations/{runId}` ile durumu sorgulayabilir.

Terminal job durumu ve SignalR eventi aynı transaction'da `recommendation.outbox_messages`
tablosuna yazılır. Outbox dispatcher geçici yayın hatalarını yeniden dener; işlenen mesajlar yedi
gün saklanır. Teslimat at-least-once olduğu için frontend `runId` ile duplicate event'leri eler.

## Testler

Unit testler ve gerçek `postgis/postgis:16-3.4-alpine` Testcontainer kullanan API integration
testleri solution içindedir. Docker çalışırken tüm paket şu komutla yürütülür:

```bash
dotnet test Rota.sln
```

Integration testleri migration, seed kalitesi, gerçek spatial sıralama, JWT/admin koruması,
`202` süresi, background completion ve retry/failure durumlarını doğrular.

Doğrudan SQL ile kontrol:

```sql
SELECT extversion FROM pg_extension WHERE extname = 'postgis';

SELECT
  (SELECT count(*) FROM discovery.neighborhoods) AS neighborhoods,
  (SELECT count(*) FROM discovery.places) AS places;

SELECT count(*) AS invalid_boundaries
FROM discovery.neighborhoods
WHERE NOT ST_IsValid(boundary) OR ST_SRID(boundary) <> 4326;

SELECT count(*) AS places_outside_neighborhood
FROM discovery.places p
JOIN discovery.neighborhoods n ON n.id = p.neighborhood_id
WHERE NOT ST_Covers(n.boundary, p.location) OR ST_SRID(p.location) <> 4326;

SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'discovery'
  AND indexname IN ('ix_neighborhoods_boundary_gist', 'ix_places_location_gist');
```

> Seed sınırları basitleştirilmiş demo poligonlarıdır; resmi idari sınır verisi değildir.
> Üretimde belediye/açık veri kaynağından gelen doğrulanmış geometriler kullanılmalıdır.
