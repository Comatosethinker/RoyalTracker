# RoyalTracker iOS Plan

The iOS version uses ReplayKit, specifically a Broadcast Upload Extension.

This is the only realistic iOS route for capturing Clash Royale frames while the game is in the foreground:

```text
User opens Control Center
-> long-presses Screen Recording
-> chooses RoyalTracker Broadcast
-> ReplayKit sends frames to the extension
-> extension detects candidate play events
-> host app or second-screen panel displays results
```

## What iOS Can Do

- Receive screen frames after the user explicitly starts the broadcast.
- Run lightweight local event detection inside the extension.
- Write compact recognition events to an App Group container.
- Send state to a companion display if the user enables that route.

## What iOS Cannot Reliably Do

- Draw a permanent floating overlay on top of Clash Royale.
- Freely inspect another app without user-initiated screen recording.
- Run a heavy model in the broadcast extension without performance risk.

## Suggested Targets

Create these targets in Xcode:

- `RoyalTrackeriOS`: SwiftUI host app
- `RoyalTrackerBroadcast`: Broadcast Upload Extension
- `RoyalTrackerShared`: shared Swift files used by both targets

Enable the same App Group on host app and extension:

```text
group.com.yourname.RoyalTracker
```

Then update `AppGroupID.swift` with the real group id.

Step-by-step Xcode setup is in [SETUP_XCODE.md](SETUP_XCODE.md).

## Files

- `Shared/AppGroupID.swift`: one place to configure the App Group id
- `Shared/SharedEventStore.swift`: file-based event transport between extension and host app
- `Shared/TrackerEvent.swift`: event schema
- `RoyalTrackeriOS/RoyalTrackeriOSApp.swift`: host app entry
- `RoyalTrackeriOS/ContentView.swift`: live event monitor UI
- `RoyalTrackerBroadcast/SampleHandler.swift`: ReplayKit frame receiver

## First Milestone

The first iOS milestone should not classify cards. It should only prove:

- the extension receives frames
- the extension detects motion bursts
- the host app sees candidate events
- events contain timestamps and confidence-like motion scores

After that, add local labeling and Core ML inference.
