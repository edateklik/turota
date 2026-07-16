# Rota AI Recommendation Service

FastAPI tabanlı MVP öneri motorudur. PostgreSQL `discovery` şemasını salt-okunur katalog
olarak kullanır ve mevcut .NET sözleşmesine uygun bölge, mekan, Timeline ve açıklama üretir.

Model `content-based-xai-v1` sürümünde şu sinyalleri kullanır:

- tercih edilen kategori: %35
- tercih edilen etiket: %30
- beslenme uyumu: %15
- bütçe uyumu: %10
- başlangıç konumuna yakınlık: %10

Mahalle skoru en iyi mekanların ortalaması, kategori çeşitliliği ve konum yakınlığından oluşur.
Timeline, seçilen mahallenin yüksek skorlu mekanlarını yakın-komşu yaklaşımıyla sıralar ve
`available_minutes` sınırını aşmaz. Algoritma aynı girdide deterministik sonuç verir.

## Çalıştırma

Tüm altyapı:

```bash
docker compose up -d --build
```

Servis dokümantasyonu `http://localhost:8000/docs`, liveness `/health/live`, veritabanı
readiness `/health/ready` adresindedir.

Recommendation endpoint'i `X-Service-Key` ister. Anahtar `SERVICE_API_KEY` environment
değişkeninden gelir ve ASP.NET `FastApi__ServiceApiKey` değeriyle aynı olmalıdır. Health
endpointleri servis anahtarı istemez.

Yalnız Python servisi:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r ai-service/requirements-dev.txt
uvicorn app.main:app --app-dir ai-service --reload
```

Test:

```bash
docker build --target test -t rota-ai-test ai-service
docker run --rm rota-ai-test
```

Production ortamında `DATABASE_URL` için yalnız `discovery` şemasında `SELECT` yetkisi olan
ayrı bir PostgreSQL kullanıcısı tercih edilmelidir.
