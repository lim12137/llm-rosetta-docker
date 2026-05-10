# LLM-Rosetta Docker

This repository publishes a deployment image for `llm-rosetta-gateway` based on the official upstream image `oaklight/llm-rosetta-gateway:latest`.

The repo keeps a small wrapper layer for four reasons:

- Build directly from the official upstream image.
- Bake a default `config.jsonc` into the image.
- Seed `/config/config.jsonc` automatically on first boot.
- Write the seeded config back to the host when no `config.jsonc` is provided in advance.

## What changed

- Default deployment now uses the published image directly in `docker-compose.yml`.
- The baked config listens on port `8765`, matching the upstream gateway default.
- A pre-created host-side `config.jsonc` is optional. The container writes one to `./config/config.jsonc` on first start.
- You can still override config with an external file when needed.

## Quick start

1. Prepare `.env`:

```bash
cp .env.example .env
```

2. Start the gateway:

```bash
docker compose up -d
```

3. Open the admin panel:

```text
http://127.0.0.1:8765/admin/
```

4. Verify health:

```bash
curl http://127.0.0.1:8765/health
```

5. Check generated host config:

```bash
ls ./config/config.jsonc
```

## Default compose deployment

The default compose file deploys the published image and mounts `./config` into the container:

```yaml
services:
  llm-rosetta:
    image: ghcr.io/lim12137/llm-rosetta-docker:latest
    ports:
      - "8765:8765"
    volumes:
      - ./config:/config
```

On first start, the image copies its baked default config to `./config/config.jsonc` on the host. After that, the admin panel writes back to the same file.
If `./config/config.jsonc` already exists on the host, the container uses it directly and does not overwrite it.

## External config override

When you want to replace the baked defaults completely, place your own config file on the host:

```yaml
services:
  llm-rosetta:
    image: ghcr.io/lim12137/llm-rosetta-docker:latest
    ports:
      - "8765:8765"
    volumes:
      - ./config/config.jsonc:/config/config.jsonc
```

Run it with:

```bash
docker compose -f docker-compose.yml -f docker-compose.external-config.yml.example up -d
```

## Image behavior

- Base image: `oaklight/llm-rosetta-gateway:latest`
- Baked config source: [config.jsonc.example](./config.jsonc.example)
- Runtime config path: `/config/config.jsonc`
- Host persistence path: `./config/config.jsonc`
- Default gateway port: `8765`
- Admin panel: `/admin/`

## Provider keys

The baked config uses environment placeholders, so you can fill keys from `.env`:

```dotenv
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
GOOGLE_API_KEY=
```

You can also leave them empty, start the service, and fill providers in `/admin/`.

## Helper commands

Initialize optional local files:

```bash
./scripts/init.sh
```

Pull and deploy:

```bash
./scripts/deploy.sh
```

View logs:

```bash
docker compose logs -f llm-rosetta
```

Stop service:

```bash
docker compose down
```
