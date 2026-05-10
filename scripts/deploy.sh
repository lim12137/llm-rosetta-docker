#!/bin/bash

set -euo pipefail

echo "Pulling image..."
docker compose pull

echo "Starting service..."
docker compose up -d

echo "Waiting for health endpoint..."
for i in $(seq 1 30); do
  if curl --silent --show-error --fail "http://127.0.0.1:${LLM_ROSETTA_PORT:-8765}/health" >/dev/null; then
    echo "Gateway is healthy."
    echo "Admin panel: http://127.0.0.1:${LLM_ROSETTA_PORT:-8765}/admin/"
    exit 0
  fi
  sleep 2
done

echo "Gateway failed health check."
docker compose logs llm-rosetta
exit 1
