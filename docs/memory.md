# Project Memory

## 2026-05-11

- Default deployment path must use a published image in `docker-compose.yml`, not a local `build`.
- The published image is a thin wrapper around `oaklight/llm-rosetta-gateway:latest`.
- The wrapper image must seed `/config/config.jsonc` from a baked default when the runtime config file is missing.
- The default compose deployment must persist that seeded config to host `./config/config.jsonc`.
- Default public access is `http://127.0.0.1:8765/admin/`.
- A pre-created host-side `config.jsonc` is optional; external override is a supported advanced path.
