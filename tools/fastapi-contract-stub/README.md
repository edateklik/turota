# FastAPI Contract Stub

Bu araç yalnızca .NET–FastAPI HTTP/JSON sözleşmesini yerelde test eder; AI modeli değildir.

```bash
python3 tools/fastapi-contract-stub/server.py
```

`availableMinutes` değerleri test senaryosu seçer: `61` timeout, `62` geçersiz JSON
sözleşmesi, `63` upstream HTTP 503; diğer geçerli değerler başarılı örnek yanıt döndürür.
