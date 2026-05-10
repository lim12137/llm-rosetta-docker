#!/bin/sh

set -eu

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"
CONFIG_DIR="/config"
CONFIG_PATH="${CONFIG_DIR}/config.jsonc"
DEFAULT_CONFIG="/defaults/config.jsonc"

if [ "$(id -u appuser)" != "$PUID" ] || [ "$(id -g appuser)" != "$PGID" ]; then
  sed -i "s/^appuser:x:[0-9]*:[0-9]*:/appuser:x:$PUID:$PGID:/" /etc/passwd
  sed -i "s/^appgroup:x:[0-9]*:/appgroup:x:$PGID:/" /etc/group
fi

mkdir -p "${CONFIG_DIR}"
chown -R appuser:appgroup "${CONFIG_DIR}"

if [ ! -f "${CONFIG_PATH}" ]; then
  echo "No host config detected. Seeding ${CONFIG_PATH} from baked default."
  cp "${DEFAULT_CONFIG}" "${CONFIG_PATH}"
  chown appuser:appgroup "${CONFIG_PATH}"
else
  echo "Using host-provided config at ${CONFIG_PATH}."
fi

exec su-exec appuser "$@"
