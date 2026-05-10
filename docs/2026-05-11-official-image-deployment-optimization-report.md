# Official Image Deployment Optimization Report

Date: 2026-05-11

## Objective

Align this repository with the successful local deployment path:

- Base on the official upstream image `oaklight/llm-rosetta-gateway:latest`
- Bake a default `config.jsonc` into the wrapper image
- Make a pre-created host-side `config.jsonc` optional by default
- Persist the first generated config back to the host automatically
- Preserve an external override path for teams that want a checked-in config file

## Changes made

- Replaced the custom Python install image with a thin wrapper `FROM oaklight/llm-rosetta-gateway:latest`
- Added `scripts/docker-entrypoint.sh` to seed `/config/config.jsonc` on first start
- Changed default compose persistence to `./config:/config` so the seeded config is written back to the host
- Switched `docker-compose.yml` to direct image deployment on port `8765`
- Added `docker-compose.external-config.yml.example` for bind-mounted config override
- Rewrote README and deployment scripts around the image-first workflow

## Validation commands

```bash
docker compose config
git diff --check
```

## Result summary

- Compose now describes direct image deployment instead of local build deployment
- Default runtime path no longer requires a pre-created host-side `config.jsonc`
- First boot is designed to materialize `./config/config.jsonc` on the host
- External config override remains available with a dedicated example file
- Local container runtime validation was not executed in this session because the Docker Desktop Linux engine was unavailable on this machine
