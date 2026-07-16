"""Local-only FastAPI contract test double; it does not contain an AI model."""

import json
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != "/api/v1/recommendations/generate":
            self.send_error(404)
            return

        length = int(self.headers.get("Content-Length", "0"))
        request = json.loads(self.rfile.read(length))
        profile = request.get("taste_profile", {})
        if (
            self.headers.get("X-Correlation-ID") != request.get("correlation_id")
            or "preferred_category_ids" not in profile
            or "preferred_tag_ids" not in profile
            or "budget_level" not in profile
            or "travel_pace" not in profile
        ):
            self._json(422, {"detail": "request contract mismatch"})
            return
        mode = request.get("available_minutes")
        if mode == 61:
            time.sleep(2)
        if mode == 62:
            self._json(200, {"invalid": True})
            return
        if mode == 63:
            self._json(503, {"detail": "simulated outage"})
            return

        response = {
            "model_version": "contract-stub-v1",
            "region": {
                "neighborhood_id": "20000000-0000-0000-0000-000000000001",
                "name": "Caferağa",
                "score": 0.94,
                "explanation": "Kafe ve vegan tercihlerinizle güçlü eşleşme.",
            },
            "places": [
                {
                    "place_id": "50000000-0000-0000-0000-000000000001",
                    "name": "Moda Kahve Noktası",
                    "score": 0.96,
                    "explanation": "Kafe tercihinizle eşleşiyor.",
                },
                {
                    "place_id": "50000000-0000-0000-0000-000000000012",
                    "name": "Moda Vegan Mutfağı",
                    "score": 0.91,
                    "explanation": "Vegan beslenme tercihinize uygun.",
                },
            ],
            "timeline": [
                {
                    "sequence": 1,
                    "place_id": "50000000-0000-0000-0000-000000000001",
                    "place_name": "Moda Kahve Noktası",
                    "start_time": "09:00:00",
                    "duration_minutes": 60,
                    "explanation": "Güne sakin bir kahve molasıyla başlangıç.",
                },
                {
                    "sequence": 2,
                    "place_id": "50000000-0000-0000-0000-000000000012",
                    "place_name": "Moda Vegan Mutfağı",
                    "start_time": "12:30:00",
                    "duration_minutes": 75,
                    "explanation": "Öğle saatinde beslenme tercihine uygun durak.",
                },
            ],
            "overall_explanation": "TasteProfile ağırlıkları bölge, mekan ve rota sıralamasında birlikte kullanıldı.",
        }
        self._json(200, response)

    def _json(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        print(f"contract-stub: {format % args}", flush=True)


if __name__ == "__main__":
    ThreadingHTTPServer(("127.0.0.1", 8000), Handler).serve_forever()
