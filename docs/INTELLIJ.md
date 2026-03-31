# JetBrains / IntelliJ Run Configurations

This repo includes shared JetBrains run configurations in `.run/` for macOS development.

These runners are macOS-only. They do not build Windows or Linux artifacts from a macOS host.

## Included runners

- `Build macOS All`
  - Runs the full qmake top-level build for all subprojects.
  - Output directory: `build/jetbrains/macos-release`
- `Run macOS Artemis`
  - Launches the built macOS app bundle from `build/jetbrains/macos-release/app/Artemis.app`

## Prerequisites

- macOS with Xcode installed
- Xcode license accepted:
  - `sudo xcodebuild -license`
- Qt 6 installed and `qmake6` available on `PATH`
- Homebrew dependencies used by the project installed:
  - `brew install qt6 ffmpeg opus sdl2 sdl2_ttf create-dmg`

## Notes

- The build runner calls `git submodule update --init --recursive` before building.
- The build uses `CONFIG+=release CONFIG+=sdk_no_version_check` and `QMAKE_MACOSX_DEPLOYMENT_TARGET=14.0`, matching the macOS CI build closely enough for local testing.
- If IntelliJ does not show the checked-in runners, make sure the Shell Script plugin is enabled and reopen the project.
