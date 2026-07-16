# Administration Module

Identity `Admin` policy ile korunan yönetim use-case'lerinin sınırıdır. Mevcut Discovery CRUD
endpointleri `/api/admin` altında bu policy ile korunmaktadır.

Administration Application ve Infrastructure katmanları iki ek use-case sağlar:

- `GET /api/admin/dashboard`: kullanıcı, katalog, Recommendation, Trip ve outbox sayaçları;
  başarı oranı, ortalama öneri süresi ve ilk 5 mahalle/mekan.
- `POST /api/admin/simulations/recommendation`: verilen TasteProfile senaryosunu gerçek
  FastAPI modelinde çalıştırır; Recommendation, Outbox veya Trip kaydı oluşturmaz.

Dashboard, modüllerin Infrastructure projelerine referans vermek yerine şemalar üzerinde
salt-okunur Npgsql read-model kullanır. Production'da `AdministrationReadDb` bağlantısına
yalnız `SELECT` yetkili ayrı bir PostgreSQL kullanıcısı verilmelidir.
