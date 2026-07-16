# Gözlemlenebilirlik ve sağlık

## Sağlık uçları

| Uç | Amaç | Kontroller |
| --- | --- | --- |
| `/health/live` | Süreç çalışıyor mu? | Uygulama süreci |
| `/health/ready` | Trafik alabilir mi? | PostgreSQL ve FastAPI readiness |
| `/health` | Geriye uyumlu readiness | PostgreSQL ve FastAPI readiness |

Readiness yanıtı her bağımlılığın durumunu ve kontrol süresini JSON olarak verir. Docker
healthcheck geriye uyumlu `/health` ucunu kullanır.

## Trace, metric ve log

ASP.NET Core istekleri, giden HTTP çağrıları ve .NET runtime metrikleri OpenTelemetry ile
enstrümante edilir. OTLP ihracı collector olmayan yerel geliştirmede gereksiz bağlantı
denemelerini önlemek için varsayılan olarak kapalıdır.

```text
Observability__OtlpEnabled=true
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
```

Production yapılandırması JSON console loglarını kullanır. Her HTTP yanıtı geçerli bir
`X-Correlation-ID` taşır; istemciden gelen değer en fazla 100 karakter ve yalnızca güvenli
alfanümerik/`-_.` karakterlerden oluşuyorsa korunur. İstek logları method, path, durum kodu,
süre, correlation ID ve trace ID alanlarını içerir; body, JWT veya parola loglanmaz.
