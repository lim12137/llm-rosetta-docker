#!/bin/bash

set -euo pipefail

echo "Preparing LLM-Rosetta deployment files..."

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example"
else
  echo ".env already exists"
fi

mkdir -p config

echo
echo "Default deployment does not require a pre-created host config.jsonc."
echo "The container will write the baked default to ./config/config.jsonc on first start."
echo "Use config/config.jsonc only when you want to override the baked config before startup."
