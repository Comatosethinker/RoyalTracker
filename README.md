# RoyalTracker

RoyalTracker is an experimental Clash Royale card-cycle and elixir tracking project.

The intended product route is iPhone-first:

- iOS Broadcast Upload Extension captures the screen after the user starts screen recording
- local recognition detects suspected opponent card plays
- results are shown through a second-screen panel, voice, Apple Watch, or a companion device
- macOS remains the fastest development and dataset-labeling tool

The project is designed as an external observation tool:

- manual opponent card logging
- estimated opponent elixir calculation
- card-cycle inference
- ScreenCaptureKit-based game-window capture
- ReplayKit Broadcast Upload Extension scaffold for iOS
- suspicious play-animation frame detection
- future local card-recognition and community labeling workflow

It does not read game memory, modify the game client, automate gameplay, or interact with Clash Royale servers.

## Status

This repository is an early MVP.

Working now:

- macOS SwiftUI app scaffold
- manual card logging
- elixir timer for 1x, 2x, and 3x phases
- likely-in-hand and recently-played cycle panels
- window selection through ScreenCaptureKit
- live capture preview
- motion-based suspicious event detection
- iOS Broadcast Extension code scaffold

Planned next:

- Xcode iOS app project and entitlements
- App Group transport between the broadcast extension and host app
- second-screen status panel
- event clip export
- local labeling UI
- dataset import/export
- baseline card classifier
- model confidence and human confirmation flow

## Requirements

macOS prototype:

- macOS 14 or newer
- Xcode or Apple Command Line Tools
- Screen Recording permission when using vision mode

iOS prototype:

- iOS 17 or newer recommended
- Xcode
- Apple Developer account for reliable device testing
- Broadcast Upload Extension target
- App Group capability shared by the host app and extension

## Run

From the repository root:

```bash
./script/build_and_run.sh
```

The app is bundled into `dist/RoyalTracker.app` and launched.

Useful modes:

```bash
./script/build_and_run.sh --verify
./script/build_and_run.sh --logs
```

You can also try SwiftPM on machines where the local SwiftPM toolchain is healthy:

```bash
swift build
```

## Usage

Manual mode:

1. Start the timer.
2. Click the card when the opponent plays it.
3. Switch elixir phase when the match reaches double or triple elixir.
4. Use star buttons to lock the opponent deck once cards are known.

Vision mode:

1. Open Clash Royale in a visible window or emulator.
2. Switch RoyalTracker to `屏幕识别`.
3. Choose the game window.
4. Press `开始识别`.
5. Grant macOS Screen Recording permission if prompted.

The current vision mode detects major visual changes and saves suspicious frames in memory. It does not yet classify the exact card.

Detected events can be exported from the Mac app. Export writes PNG frames and a `labels.jsonl` draft to:

```text
~/Documents/RoyalTracker/Captures/
```

Those files are intended for local review and labeling, not automatic upload.

iOS route:

1. Install the host app through Xcode, TestFlight, or side loading.
2. Open Control Center on iPhone.
3. Long-press Screen Recording.
4. Choose the RoyalTracker broadcast extension.
5. Start the broadcast.
6. The extension receives screen frames and forwards recognition events to the host app or a second-screen panel.

See [iOS/README.md](iOS/README.md).

## Recognition Approach

RoyalTracker should recognize the moment of card deployment rather than treating every new battlefield unit as a played card. This matters because cards such as Witch, Night Witch, buildings, clone effects, and death spawns can create new units that are not new card plays.

The intended pipeline:

```text
screen frames
-> suspicious deployment event
-> short clip around the event
-> card candidate classifier
-> rule filters for summons, clone effects, buildings, and repeated events
-> confidence score
-> automatic log or user confirmation
```

## Contributing Data

The project is intended to support opt-in community labeling. See [docs/DATASET.md](docs/DATASET.md).

Do not upload full private recordings by default. Prefer cropped event clips with labels.

Training should happen in a private lab repository. See [docs/TRAINING_PIPELINE.md](docs/TRAINING_PIPELINE.md).

## Distribution Plan

- GitHub: source code, issues, dataset schema, contributor docs
- Side loading: technical users can build with Xcode and install to their own devices
- TestFlight: practical early-user distribution
- App Store: not the first target because review risk is higher for game-adjacent screen-recognition tools

## Disclaimer

RoyalTracker is an unofficial community project and is not affiliated with, endorsed by, or sponsored by Supercell. Clash Royale is a trademark of Supercell.
