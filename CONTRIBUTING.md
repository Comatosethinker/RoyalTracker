# Contributing

Thanks for helping build RoyalTracker.

## Project Boundaries

Allowed contributions:

- screen capture and visual recognition
- local labeling tools
- card-cycle and elixir estimation
- local model inference
- opt-in dataset export/import

Out of scope:

- reading or modifying game memory
- packet interception or server protocol work
- injecting code into the game client or emulator
- gameplay automation
- bypassing platform or game protections

## Development

Run the app:

```bash
./script/build_and_run.sh
```

Check compile without launching:

```bash
CLANG_MODULE_CACHE_PATH="$PWD/.build-cache/clang" \
  xcrun swiftc -parse-as-library $(find Sources/RoyalTracker -name '*.swift' | sort) \
  -o /tmp/RoyalTrackerCheck
```

## Pull Requests

Good first areas:

- improve card catalog coverage
- add event export format
- add local labeling UI
- tune motion detection
- improve ScreenCaptureKit error messages
- turn the iOS scaffold into a complete Xcode project
- wire App Group entitlements for the host app and broadcast extension
- add classifier interfaces and tests

Keep PRs small and focused. For recognition work, include sample cases and explain false positives.

## Data Contributions

Data should be opt-in and privacy-conscious. Prefer cropped event clips, not full matches. See [docs/DATASET.md](docs/DATASET.md).
