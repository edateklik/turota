"""Harici paket gerektirmeyen, hızlı yerel performans smoke testi.

Kullanım: BASE_URL=http://localhost:5121 python3 tests/load/smoke.py
"""
import json
import os
import statistics
import time
import urllib.error
import urllib.request

BASE_URL = os.environ.get("BASE_URL", "http://localhost:5121").rstrip("/")


def request(method, path, payload=None, token=None):
    body = json.dumps(payload).encode() if payload is not None else None
    headers = {"Content-Type": "application/json"} if body else {}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(BASE_URL + path, data=body, headers=headers, method=method)
    started = time.perf_counter()
    try:
        with urllib.request.urlopen(req, timeout=5) as response:
            data = response.read()
            return response.status, json.loads(data) if data else None, time.perf_counter() - started
    except urllib.error.HTTPError as error:
        return error.code, None, time.perf_counter() - started


unique = f"{int(time.time())}@example.com"
status, registered, _ = request("POST", "/api/identity/register", {
    "email": unique, "password": "SmokeTest123!", "firstName": "Smoke", "lastName": "Test"
})
if status != 201:
    raise SystemExit(f"register failed: HTTP {status}")

token = registered["accessToken"]
durations = []
for _ in range(20):
    status, places, elapsed = request(
        "GET", "/api/discovery/places/nearest?longitude=29.026&latitude=40.985&limit=20"
    )
    if status != 200 or not places:
        raise SystemExit(f"spatial query failed: HTTP {status}")
    durations.append(elapsed * 1000)

durations.sort()
p95 = durations[max(0, int(len(durations) * 0.95) - 1)]
print(f"spatial requests={len(durations)} p95_ms={p95:.1f} avg_ms={statistics.mean(durations):.1f}")
if p95 >= 500:
    raise SystemExit("spatial p95 threshold exceeded (500 ms)")

status, _, elapsed = request("POST", "/api/recommendations/generate", {
    "tripDate": "2099-01-01", "availableMinutes": 240,
    "startLongitude": 29.026, "startLatitude": 40.985
}, token)
print(f"recommendation status={status} enqueue_ms={elapsed * 1000:.1f}")
if status != 202:
    raise SystemExit("recommendation was not accepted")
