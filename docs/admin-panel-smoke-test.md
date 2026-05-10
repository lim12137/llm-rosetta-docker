# Admin Panel Smoke Test

Date: 2026-05-11

## Goal

- Verify the wrapper image starts from the official upstream base image.
- Verify the baked config is seeded to `/config/config.jsonc` on first boot.
- Verify the seeded config is persisted to host `./config/config.jsonc`.
- Verify `/health`, `/admin/`, and `/v1/models` are reachable.
- Verify external config can override the baked default.

## Expected commands

Default deployment:

```bash
mkdir -p config
docker compose up -d
test -f config/config.jsonc
curl http://127.0.0.1:8765/health
curl -I http://127.0.0.1:8765/admin/
curl http://127.0.0.1:8765/v1/models
```

External override deployment:

```bash
mkdir -p config
cp config.jsonc.example config/config.jsonc
docker compose -f docker-compose.yml -f docker-compose.external-config.yml.example up -d
```

CI smoke test:

```bash
mkdir -p config
docker build -t llm-rosetta-gateway:test .
docker run -d --name llm-rosetta-default -p 8765:8765 \
  -v "$PWD/config:/config" \
  llm-rosetta-gateway:test
test -f config/config.jsonc
curl --retry 15 --retry-delay 2 --retry-connrefused http://127.0.0.1:8765/health
curl --fail http://127.0.0.1:8765/admin/
curl --fail http://127.0.0.1:8765/v1/models

cp config.jsonc.example config/config.jsonc
docker run -d --name llm-rosetta-override -p 8766:8765 \
  -v "$PWD/config/config.jsonc:/config/config.jsonc" \
  llm-rosetta-gateway:test
curl --retry 15 --retry-delay 2 --retry-connrefused http://127.0.0.1:8766/health
curl --fail http://127.0.0.1:8766/admin/
```

## Notes

- Default deployment should not require a pre-created host-side `config.jsonc`.
- The first successful start should create `./config/config.jsonc` automatically.
- External override is only needed when you want to replace the baked config or keep it in Git.
