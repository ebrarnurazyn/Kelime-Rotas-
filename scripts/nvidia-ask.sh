#!/usr/bin/env bash
# Kullanım: ./scripts/nvidia-ask.sh "sorunuz / göreviniz burada"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

if [ -z "${NVIDIA_API_KEY:-}" ]; then
  echo "Hata: NVIDIA_API_KEY tanımlı değil." >&2
  echo "Proje kökünde bir .env dosyası oluşturun ve içine şunu ekleyin:" >&2
  echo "  NVIDIA_API_KEY=nvapi-...(kendi anahtarınız)" >&2
  echo "(Örnek için .env.example dosyasına bakabilirsiniz.)" >&2
  exit 1
fi

if [ -z "${1:-}" ]; then
  echo "Kullanım: $0 \"soru/görev metni\"" >&2
  exit 1
fi

MODEL="${NVIDIA_MODEL:-meta/llama-3.1-8b-instruct}"

BODY="$(python3 -c '
import json, sys
model, prompt = sys.argv[1], sys.argv[2]
print(json.dumps({
    "model": model,
    "messages": [{"role": "user", "content": prompt}],
    "temperature": 0.2,
    "max_tokens": 500
}))
' "$MODEL" "$1")"

curl -s --request POST \
  --url https://integrate.api.nvidia.com/v1/chat/completions \
  --header "Authorization: Bearer ${NVIDIA_API_KEY}" \
  --header "Content-Type: application/json" \
  --data "$BODY" \
| python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    print(d["choices"][0]["message"]["content"])
except Exception:
    print(sys.stdin.read() if False else json.dumps(d, ensure_ascii=False, indent=2))
'
