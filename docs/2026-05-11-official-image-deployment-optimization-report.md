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

## Follow-up fix for failed GitHub Actions smoke test

- The wrapper entrypoint originally appended `llm-rosetta-gateway` unconditionally.
- The upstream base image likely already provides a default `CMD`, which caused the wrapper to pass a duplicated command into the final process.
- The entrypoint was updated to strip a leading inherited `llm-rosetta-gateway`, run the gateway with `--config` when no explicit command is supplied, and preserve custom commands when users override the container command.
- A second likely failure source is write permission on the bind-mounted host `./config` directory.
- The wrapper image now switches to `USER root` before seeding `/config/config.jsonc`, so first-boot persistence to the host path is not blocked by upstream rootless defaults.

## Follow-up fix after reading upstream Docker source

- The upstream image already ships a custom `/entrypoint.sh`.
- That entrypoint normalizes `PUID/PGID`, fixes `/config` ownership, and starts the gateway through `su-exec`.
- The wrapper entrypoint is now aligned with the upstream logic instead of bypassing it.
- The only intentional behavior change is the missing-config branch:
  it now copies the baked default config to `/config/config.jsonc` instead of running `llm-rosetta-gateway init`.
