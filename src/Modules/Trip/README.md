# Trip Module

Günlük rota ve Timeline aggregate'larının sınırıdır. Tamamlanan Recommendation outbox olayı
idempotent olarak tüketilir; mekan koordinatları Discovery'nin salt-okunur portundan alınır.
`trip.trips` ve `trip.trip_stops` tabloları diğer modül tablolarına database foreign key
kurmadan kaynak kimliklerini saklar.

Timeline; 1-50 sıralı durak, 30-720 dakikalık kullanılabilir süre, pozitif durak süreleri,
gece yarısını aşmama ve zaman çakışmama kurallarıyla korunur. Rota durumu yalnızca
`Planned → Cancelled` veya `Planned → Completed` yönünde değişebilir.

Rezervasyon, ödeme ve gerçek zamanlı trafik MVP kapsamı dışındadır.
