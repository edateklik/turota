# Performans kalite kapısı

MVP yük profili iki kritik akışı aynı anda çalıştırır:

- PostGIS en yakın mekan sorgusu: 20 istek/saniye, 30 saniye.
- Asenkron öneri kabulü: 0,5 istek/saniye, 30 saniye.

Başarı eşikleri genel `p95 < 2 saniye`, spatial `p95 < 500 ms`, HTTP hata oranı `< %1`,
check başarı oranı `> %99` ve sıfır dropped iteration'dır. Öneri üretimi asenkron olduğu için
ölçülen süre `202 Accepted` kalıcı kuyruğa alma süresidir; FastAPI sonucu readiness ve E2E
testleriyle ayrıca doğrulanır.

Normal rate limit değerleri gerçek trafik için korunur. Kontrollü yerel yük testi:

```bash
RATE_LIMIT_GLOBAL_PERMIT=10000 \
RATE_LIMIT_RECOMMENDATION_PERMIT=10000 \
docker compose --profile load up -d --force-recreate api

RATE_LIMIT_GLOBAL_PERMIT=10000 \
RATE_LIMIT_RECOMMENDATION_PERMIT=10000 \
docker compose --profile load run --rm load-test

docker compose --profile load down
docker compose up -d
```

Son iki komut API'yi `.env` içindeki güvenli varsayılan limitlerle yeniden başlatır. Yük testi
üretim ortamına veya paylaşılan veritabanına karşı çalıştırılmamalıdır.

Docker registry erişimi olmayan geliştirme ortamlarında aynı profil ve eşikler harici paket
gerektirmeyen yedek çalıştırıcıyla ölçülebilir:

```bash
python3 tests/load/smoke.py
```
