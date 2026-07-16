# Trip ve Timeline

Trip modülü, tamamlanan AI önerisini kullanıcıya sunulabilir ve haritada çizilebilir kalıcı
bir günlük rotaya dönüştürür. `recommendation.completed.v1` olayı Transactional Outbox ile
en az bir kez teslim edilir. Tüketici `source_recommendation_run_id` unique index'i sayesinde
aynı öneri için yalnız bir Trip oluşturur.

## REST sözleşmesi

Tüm uçlar `User` JWT policy'siyle korunur ve yalnız token içindeki `sub` kullanıcısının
kayıtlarına erişir.

```text
GET  /api/trips?page=1&pageSize=20
GET  /api/trips/{tripId}
POST /api/trips/{tripId}/cancel
POST /api/trips/{tripId}/complete
```

Sayfa boyutu en fazla 50'dir. Detay yanıtındaki her durak; sıra, mekan kimliği/adı, başlangıç
saati, süre, açıklama, longitude ve latitude değerlerini taşır. Geçersiz ikinci durum geçişi
`409 TRIP_STATE_CONFLICT`, başka kullanıcıya ait ya da bulunmayan rota `404 NOT_FOUND` döner.

## Veri ve modül sınırları

- `trip.trips`: kullanıcı, kaynak öneri, tarih, bölge, açıklama ve durum.
- `trip.trip_stops`: sıralı Timeline ve harita koordinat snapshot'ı.
- Recommendation ve Discovery tablolarına çapraz foreign key yoktur.
- Koordinatlar Trip oluşturulurken snapshot alınır; sonradan mekan düzenlemesi geçmiş rotayı değiştirmez.
- Olay işleme başarısızsa outbox yeniden dener; eksik mekan koordinatı sessizce atlanmaz.

Migration:

```bash
dotnet ef database update \
  --project src/Modules/Trip/Rota.Modules.Trip.Infrastructure \
  --context TripDbContext
```
