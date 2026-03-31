#!/bin/zsh

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This runner only supports macOS."
  exit 1
fi

ROOT_DIR=$(cd -- "$(dirname "$0")/../.." && pwd)
BUILD_DIR="${ARTEMIS_JB_BUILD_DIR:-$ROOT_DIR/build/jetbrains/macos-release}"
APP_EXEC="$BUILD_DIR/app/Artemis.app/Contents/MacOS/Artemis"

if [[ ! -x "$APP_EXEC" ]]; then
  echo "The macOS app bundle has not been built yet."
  echo "Run the 'Build macOS All' configuration first."
  echo "Expected executable:"
  echo "  $APP_EXEC"
  exit 1
fi

exec "$APP_EXEC" "$@"
