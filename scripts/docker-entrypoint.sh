#!/bin/sh

set -eu

CONFIG_DIR="/config"
CONFIG_PATH="${CONFIG_DIR}/config.jsonc"
DEFAULT_CONFIG="/defaults/config.jsonc"

mkdir -p "${CONFIG_DIR}"

if [ ! -f "${CONFIG_PATH}" ]; then
  echo "No host config detected. Seeding ${CONFIG_PATH} from baked default."
  cp "${DEFAULT_CONFIG}" "${CONFIG_PATH}"
else
  echo "Using host-provided config at ${CONFIG_PATH}."
fi

if [ "$#" -gt 0 ] && [ "$1" = "llm-rosetta-gateway" ]; then
  shift
fi

if [ "$#" -eq 0 ]; then
  exec llm-rosetta-gateway --config "${CONFIG_PATH}"
fi

case "$1" in
  -*)
    exec llm-rosetta-gateway --config "${CONFIG_PATH}" "$@"
    ;;
  *)
    exec "$@"
    ;;
esac
