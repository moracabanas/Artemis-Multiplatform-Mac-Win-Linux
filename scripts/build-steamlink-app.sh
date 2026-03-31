#!/bin/sh
echo "Deprecated: use scripts/legacy/linux/build-steamlink-app.sh." >&2
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
exec "$SCRIPT_DIR/legacy/linux/build-steamlink-app.sh" "$@"
