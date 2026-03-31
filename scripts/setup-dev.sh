#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

OS="unknown"
case "$(uname -s)" in
  Linux) OS="linux" ;;
  Darwin) OS="macos" ;;
  MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
esac

SKIP_DEPS=false
SKIP_BUILD=false

usage() {
  cat <<'EOF'
Usage: ./scripts/setup-dev.sh [options]

Options:
  --skip-deps   Skip dependency installation
  --skip-build  Skip the initial debug build
  --help, -h    Show this help
EOF
}

install_dependencies() {
  case "$OS" in
    linux)
      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y \
          build-essential git qt6-base-dev qt6-declarative-dev libqt6svg6-dev \
          qml6-module-qtquick-controls qml6-module-qtquick-templates \
          qml6-module-qtquick-layouts qml6-module-qtqml-workerscript \
          qml6-module-qtquick-window qml6-module-qtquick \
          libegl1-mesa-dev libgl1-mesa-dev libopus-dev libsdl2-dev \
          libsdl2-ttf-dev libssl-dev libavcodec-dev libavformat-dev \
          libswscale-dev libva-dev libvdpau-dev libxkbcommon-dev \
          wayland-protocols libdrm-dev
      elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y \
          gcc-c++ git qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtsvg-devel \
          openssl-devel SDL2-devel SDL2_ttf-devel ffmpeg-devel libva-devel \
          libvdpau-devel opus-devel pulseaudio-libs-devel alsa-lib-devel libdrm-devel
      else
        echo "Unsupported Linux distribution. Install the dependencies from README.md manually."
        exit 1
      fi
      ;;
    macos)
      if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required on macOS."
        exit 1
      fi
      brew install qt6 ffmpeg opus sdl2 sdl2_ttf create-dmg
      ;;
    windows)
      cat <<'EOF'
Install these prerequisites manually on Windows:
  1. Qt 6.7+ with qmake
  2. Visual Studio 2022 with MSVC
  3. 7-Zip
EOF
      ;;
    *)
      echo "Unsupported operating system."
      exit 1
      ;;
  esac
}

init_submodules() {
  git -C "$ROOT_DIR" submodule update --init --recursive
}

build_project() {
  if command -v qmake6 >/dev/null 2>&1; then
    QMAKE=qmake6
  elif command -v qmake >/dev/null 2>&1; then
    QMAKE=qmake
  else
    echo "qmake6 or qmake is required."
    exit 1
  fi

  cd "$ROOT_DIR"
  rm -f .qmake.stash .qmake.cache
  find . -name "Makefile*" -delete 2>/dev/null || true

  if [ "$OS" = "macos" ] && ! xcrun --show-sdk-path >/dev/null 2>&1; then
    echo "macOS SDK unavailable. If Xcode is installed, run: sudo xcodebuild -license"
    exit 1
  fi

  "$QMAKE" artemis.pro CONFIG+=debug

  if [ "$OS" = "macos" ]; then
    make -j"$(sysctl -n hw.ncpu)"
  else
    make -j"$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)"
  fi
}

show_next_steps() {
  cat <<'EOF'
Setup complete.

Next steps:
  1. Build manually with qmake6 artemis.pro CONFIG+=debug or CONFIG+=release
  2. On macOS in IntelliJ, use the shared runners:
     - Build macOS All
     - Run macOS Artemis
  3. See docs/BUILD_SYSTEM.md and docs/INTELLIJ.md for packaging and IDE details
EOF
}

if [ ! -f "$ROOT_DIR/artemis.pro" ]; then
  echo "artemis.pro was not found. Run this script from inside the repository."
  exit 1
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --skip-deps) SKIP_DEPS=true ;;
    --skip-build) SKIP_BUILD=true ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

if [ "$SKIP_DEPS" != true ]; then
  install_dependencies
fi

init_submodules

if [ "$SKIP_BUILD" != true ]; then
  build_project
fi

show_next_steps
