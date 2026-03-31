# Artemis Multiplatform

Artemis Multiplatform Works on Mac, Windows, and Linux. Im doing this on mac, so bare with me to get the others working.

## Repository layout

- `artemis.pro`
  - Top-level qmake project. Builds the full workspace.
- `app/`
  - Main desktop application, QML UI, backend managers, and streaming integration.
- `moonlight-common-c/`
  - Upstream streaming core library.
- `qmdnsengine/`
  - Discovery and networking support.
- `h264bitstream/`
  - Codec bitstream helpers.
- `soundio/`, `AntiHooking/`
  - Platform-specific support libraries.
- `scripts/`
  - Build, packaging, and developer helper scripts.
- `docs/`
  - Build, IDE, and platform notes.

## Build requirements

All platforms:

- Qt 6.7+ with `qmake6`
- FFmpeg
- SDL2 and SDL2_ttf
- OpenSSL
- Opus
- Git submodules initialized

Platform notes:

- macOS: Xcode and accepted Xcode license, `create-dmg`
- Windows: Visual Studio 2022 with MSVC, WiX for installer packaging
- Linux: distro development packages for Qt, FFmpeg, SDL2, OpenSSL, and related graphics libraries

## Quick start

```bash
git submodule update --init --recursive
qmake6 artemis.pro CONFIG+=release
make -j$(sysctl -n hw.ncpu)   # macOS
make -j$(nproc)               # Linux
```

Windows is built from a Visual Studio developer shell or CI using the scripts under `scripts/windows/`.

Packaging is host-platform specific:

- macOS hosts build macOS artifacts
- Linux hosts build Linux artifacts
- Windows hosts build Windows artifacts

Cross-host packaging is not supported by the checked-in scripts.

## Build entrypoints

- `scripts/setup-dev.sh`
  - Installs dependencies where supported, initializes submodules, and performs an initial debug build.
- `scripts/windows/build-artemis-arch.bat`
  - Windows architecture build and packaging entrypoint used by CI.
- `scripts/windows/generate-artemis-bundle.bat`
  - Windows universal installer entrypoint.
- `scripts/macos/generate-dmg.sh`
  - macOS DMG packaging entrypoint.
- `scripts/linux/build-appimage.sh`
  - Linux AppImage packaging entrypoint.
- `scripts/shared/generate-src.sh`
  - Source archive helper.

Compatibility wrappers remain at the old top-level script paths in `scripts/` and forward to the organized locations above.

## IntelliJ / JetBrains

Shared run configurations live in `.run/`.

- `Build macOS All`
- `Run macOS Artemis`

See [docs/INTELLIJ.md](docs/INTELLIJ.md) for details.

## Additional docs

- [docs/BUILD_SYSTEM.md](docs/BUILD_SYSTEM.md)
- [docs/WINDOWS_ARM64.md](docs/WINDOWS_ARM64.md)
- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)
