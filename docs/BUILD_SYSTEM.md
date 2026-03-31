# Build System

This repository uses qmake with `artemis.pro` as the top-level project. Platform packaging is handled by scripts grouped under `scripts/windows/`, `scripts/macos/`, `scripts/linux/`, and `scripts/shared/`.

Packaging is host-platform specific. The checked-in scripts do not support building Windows packages from macOS/Linux, Linux packages from macOS/Windows, or macOS packages from Linux/Windows.

## Core build

```bash
git submodule update --init --recursive
qmake6 artemis.pro CONFIG+=release
make -j$(sysctl -n hw.ncpu)   # macOS
make -j$(nproc)               # Linux
```

For a debug build, replace `CONFIG+=release` with `CONFIG+=debug`.

## Script layout

- `scripts/windows/build-artemis-arch.bat`
  - Builds Windows artifacts for the active Qt/MSVC target architecture.
- `scripts/windows/generate-artemis-bundle.bat`
  - Builds the universal Windows installer bundle after the per-architecture MSI builds exist.
- `scripts/macos/generate-dmg.sh`
  - Builds the universal macOS app and packages it into a DMG.
- `scripts/linux/build-appimage.sh`
  - Builds and packages the Linux AppImage.
- `scripts/shared/generate-src.sh`
  - Produces a source archive.
- `scripts/legacy/`
  - Older Moonlight-era entrypoints kept only for compatibility.

The old top-level script names in `scripts/` are now wrappers that forward to the organized locations above.

## Windows

Per-architecture build:

```bat
scripts\windows\build-artemis-arch.bat release
```

Universal bundle:

```bat
scripts\windows\generate-artemis-bundle.bat release
```

CI uses the same batch files from `.github/workflows/dev-build.yml`.

## macOS

Package a DMG:

```bash
./scripts/macos/generate-dmg.sh Release
```

Local IntelliJ development can use the shared `.run` configurations documented in [docs/INTELLIJ.md](./INTELLIJ.md).

## Linux

Package an AppImage:

```bash
./scripts/linux/build-appimage.sh
```

## Source archive

```bash
./scripts/shared/generate-src.sh
```

## Notes

- The top-level project is `artemis.pro`, not `moonlight-qt.pro`.
- macOS local builds require Xcode and an accepted Xcode license:
  - `sudo xcodebuild -license`
- The GitHub Actions workflow in [`.github/workflows/dev-build.yml`](/Users/brianfopiano/Developer/RemoteGit/NextdoorPsycho/Mac-atremis-updated/.github/workflows/dev-build.yml) is the canonical CI build definition.
