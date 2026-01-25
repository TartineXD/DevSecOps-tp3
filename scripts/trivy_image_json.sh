#!/usr/bin/env bash
set -euo pipefail
IMAGE="${1:-}"
if [[ -z "$IMAGE" ]]; then
  echo "Usage: $0 <image>"
  exit 1
fi
mkdir -p reports
OUT="reports/trivy-image-$(echo "$IMAGE" | tr '/:' '__').json"
trivy image --format json --output "$OUT" "$IMAGE"
echo "Report written: $OUT"
