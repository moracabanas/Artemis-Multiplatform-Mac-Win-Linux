#!/bin/zsh

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This runner only supports macOS."
  exit 1
fi

ROOT_DIR=$(cd -- "$(dirname "$0")/../.." && pwd)
BUILD_DIR="${ARTEMIS_JB_BUILD_DIR:-$ROOT_DIR/build/jetbrains/macos-release}"
DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-14.0}"
THREADS=$(sysctl -n hw.ncpu)

if ! command -v qmake6 >/dev/null 2>&1; then
  echo "qmake6 is not on PATH. Install Qt 6 and make sure qmake6 is available."
  exit 1
fi

if ! xcrun --show-sdk-path >/dev/null 2>&1; then
  echo "The macOS SDK is not available to xcrun."
  echo "If Xcode is installed, run: sudo xcodebuild -license"
  exit 1
fi

echo "Using repository: $ROOT_DIR"
echo "Using build dir:   $BUILD_DIR"
echo "Using threads:     $THREADS"

git -C "$ROOT_DIR" submodule update --init --recursive
mkdir -p "$BUILD_DIR"

cd "$BUILD_DIR"

export MACOSX_DEPLOYMENT_TARGET="$DEPLOYMENT_TARGET"

qmake6 "$ROOT_DIR/artemis.pro" \
  CONFIG+=release \
  CONFIG+=sdk_no_version_check \
  "QMAKE_MACOSX_DEPLOYMENT_TARGET=$DEPLOYMENT_TARGET"

make -j"$THREADS" qmake_all
make -j"$THREADS"

APP_EXEC="$BUILD_DIR/app/Artemis.app/Contents/MacOS/Artemis"
if [[ ! -x "$APP_EXEC" ]]; then
  echo "Build completed but the macOS app executable was not found at:"
  echo "  $APP_EXEC"
  exit 1
fi

echo
echo "Build complete."
echo "App executable: $APP_EXEC"
