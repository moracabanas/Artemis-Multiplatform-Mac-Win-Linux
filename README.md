# Artemis Desktop

Artemis Desktop is a Qt-based streaming client for Apollo-compatible hosts, with the desktop-side Apollo feature work carried forward into a macOS-first codebase.

The host/server project this client is built around is [Apollo](https://github.com/ClassicOldSong/Apollo). This repository focuses on the client side: pairing, host discovery, app browsing, streaming, Apollo-specific permissions, clipboard integration, server commands, and desktop packaging. The current work here is centered on keeping that feature set available in a native desktop client, with macOS receiving the most active attention.

Ill also likely be redesigning it in dart away from QT, i just wanted something working as of now. 

## Interface

![Artemis desktop walkthrough](Assets/Psy-d3TCbwvC-Artemis.gif)

<p align="center">
  <img src="Assets/Psy-ciilY4QI-Artemis.png" alt="Artemis computer browser" width="48%" />
  <img src="Assets/Psy-m0D4wkIL-Artemis.png" alt="Artemis settings view" width="48%" />
</p>

## What It Does

- Discovers compatible hosts on the local network with mDNS and also supports manual host registration.
- Connects to Apollo-compatible hosts, reads host capabilities, and tracks host state such as pairing, active sessions, and app availability.
- Supports standard PIN pairing as well as Apollo OTP / passphrase pairing on hosts that advertise it.
- Browses exported applications from the host and launches or resumes sessions from the desktop client.
- Understands Apollo's permission model, including launch permissions, clipboard permissions, and server-command permissions.
- Synchronizes clipboard data with Apollo hosts through the Apollo clipboard endpoint when the paired client is allowed to do so.
- Exposes Apollo server commands in the desktop client and in the in-session quick menu when the host grants that capability.
- Integrates desktop streaming controls such as display mode, input behavior, codec selection, HDR, bitrate control, and stream-session actions.

## Apollo-Specific Client Features

This fork is meant to carry the Apollo-side client behavior into the desktop application rather than leaving those features exclusive to other clients.

- Apollo host detection and permission parsing are implemented in the desktop client.
- Launch permission is checked before trying to start an app, so the client can explain a `403` style permission failure instead of failing silently.
- OTP pairing is implemented with Apollo's desktop-side authentication flow.
- Clipboard sync is implemented against Apollo's `/actions/clipboard` behavior.
- Server commands are wired into the client and gated by Apollo permissions.
- Apollo-specific host capabilities such as virtual display support and permission-aware actions are surfaced in the UI and runtime behavior.

## Streaming And Desktop Stack

- Qt/QML desktop UI with platform-native packaging and shared desktop runners for JetBrains.
- FFmpeg-based decode path with platform-specific renderer selection.
- On macOS, the build uses VideoToolbox and Metal-backed rendering paths where supported.
- HEVC, AV1, HDR, and related codec/renderer capability probing are handled at runtime based on host and client support.
- Bitrate tuning supports normal slider-based adjustment up to `500 Mbps`, plus higher custom values for high-bandwidth local-network testing.
- The quick menu includes stream controls, clipboard actions, and Apollo server-command integration during an active session.

## Build Model

Build and packaging are host-platform specific.

- macOS builds macOS artifacts
- Windows builds Windows artifacts
- Linux builds Linux artifacts

The checked-in scripts do not support cross-host packaging. A macOS machine does not produce Windows or Linux packages, and the inverse is also true.

## Quick Start

Initialize submodules first:

```bash
git submodule update --init --recursive
```

Build the full workspace with qmake:

```bash
qmake6 artemis.pro CONFIG+=release
make -j$(sysctl -n hw.ncpu)   # macOS
make -j$(nproc)               # Linux
```

On Windows, use the scripts in `scripts/windows/` from a Visual Studio developer shell.

## JetBrains / IntelliJ

Shared run configurations are included in `.run/`.

- `Build macOS All`
- `Run macOS Artemis`

These runners are for macOS development only. See [docs/INTELLIJ.md](docs/INTELLIJ.md) for details.

## Repository Layout

- `artemis.pro`
  - Top-level qmake project that builds the workspace.
- `app/`
  - Desktop application, QML UI, backend managers, streaming integration, and platform glue.
- `moonlight-common-c/`
  - Core streaming library used by the client.
- `qmdnsengine/`
  - Host discovery and network service support.
- `h264bitstream/`
  - Bitstream helpers used by the streaming pipeline.
- `soundio/`, `AntiHooking/`
  - Supporting platform libraries and low-level integration code.
- `scripts/`
  - Build, packaging, and developer helper scripts.
- `docs/`
  - Build notes, IDE notes, and platform-specific documentation.
- `Assets/`
  - README media and project screenshots.

## Additional Documentation

- [docs/BUILD_SYSTEM.md](docs/BUILD_SYSTEM.md)
- [docs/INTELLIJ.md](docs/INTELLIJ.md)
- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)
- [docs/WINDOWS_ARM64.md](docs/WINDOWS_ARM64.md)
