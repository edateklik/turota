# Identity, JWT ve Frontend Sözleşmesi

## Endpointler

| Metot | Yol | Yetki | Başarılı yanıt |
|---|---|---|---|
| POST | `/api/identity/register` | Anonim | `201 AuthResponse` |
| POST | `/api/identity/login` | Anonim | `200 AuthResponse` |
| GET | `/api/identity/me` | Bearer | `200 UserResponse` |
| GET | `/api/identity/me/taste-profile` | Bearer | `200 TasteProfileResponse` |
| PUT | `/api/identity/me/taste-profile` | Bearer | `200 TasteProfileResponse` |
| CRUD | `/api/admin/**` | `Admin` rolü | Kaynağa göre |

`AuthResponse.accessToken`, React/Flutter tarafından `Authorization: Bearer {token}` header'ında
gönderilir. `tokenType` değeri `Bearer`, `expiresAt` değeri UTC ISO-8601'dir. V1'de refresh
token yoktur; süre dolduğunda yeniden login gerekir.

## TasteProfile

- `preferredCategoryIds`: Discovery kategori kimlikleri, en fazla 50.
- `preferredTagIds`: Discovery etiket kimlikleri, en fazla 50.
- `dietaryPreferences`: En fazla 20 serbest metin tercih.
- `budgetLevel`: `Economy`, `Moderate`, `Premium`.
- `travelPace`: `Relaxed`, `Balanced`, `Intensive`.

Identity ile Discovery arasında database foreign key kurulmaz. Recommendation modülü bu
kimlikleri okuyup geçerlilik/skorlama işini modül sözleşmeleri üzerinden yapacaktır.

## JWT güvenlik ayarları

Token doğrulaması issuer, audience, HMAC-SHA256 imza, expiration ve 30 saniye clock-skew
kontrollerini içerir. Varsayılan süre 60 dakikadır. Production anahtarı repoya yazılmaz:

```bash
export Jwt__SigningKey='en-az-32-byte-uzunlugunda-guvenli-production-secret'
export Jwt__Issuer='Rota.Api'
export Jwt__Audience='Rota.Clients'
```

Kullanıcı parolaları ASP.NET Core `PasswordHasher<TUser>` ile hashlenir. E-posta lookup'u
normalize edilmiş unique index üzerinden yapılır. API hiçbir yanıtta hash döndürmez.

## Swagger

Development ortamında:

```text
UI:   http://localhost:5121/swagger
JSON: http://localhost:5121/swagger/v1/swagger.json
```

Swagger UI'daki **Authorize** düğmesine yalnızca token değeri girilir. Login/Register anonim,
`/me` ve Admin operasyonları Bearer security requirement ile işaretlenir. Production'da
Swagger middleware varsayılan olarak kapalıdır.
