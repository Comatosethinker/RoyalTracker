# Xcode Setup

This repository keeps the iOS scaffold as plain Swift files first. The next step is to create a normal Xcode project and add these files to the right targets.

## 1. Create the Host App

1. Open Xcode.
2. Create a new iOS App project named `RoyalTrackeriOS`.
3. Use SwiftUI and Swift.
4. Add the files from `iOS/RoyalTrackeriOS/`.

## 2. Add the Broadcast Extension

1. Select the Xcode project.
2. Add a new target.
3. Choose `Broadcast Upload Extension`.
4. Name it `RoyalTrackerBroadcast`.
5. Add `iOS/RoyalTrackerBroadcast/SampleHandler.swift` to this target.

## 3. Add Shared Files

Add these files to both the host app and broadcast extension targets:

- `iOS/Shared/AppGroupID.swift`
- `iOS/Shared/TrackerEvent.swift`
- `iOS/Shared/SharedEventStore.swift`
- `iOS/Shared/MotionBurstDetector.swift`

## 4. Enable App Groups

For both targets:

1. Open `Signing & Capabilities`.
2. Add `App Groups`.
3. Create or select the same group, for example:

```text
group.com.yourname.RoyalTracker
```

4. Update `iOS/Shared/AppGroupID.swift` with that exact value.

## 5. Test on Device

Broadcast extensions should be tested on a real iPhone:

1. Install the host app.
2. Open Control Center.
3. Long-press Screen Recording.
4. Choose `RoyalTrackerBroadcast`.
5. Start recording.
6. Open the host app to see candidate events.

## 6. First Validation Goal

Do not start with card recognition. First validate that:

- `broadcast started` appears in the host app
- candidate motion events appear while Clash Royale is visible
- stopping the broadcast writes `broadcast finished`

Only after this is stable should the project add clip export and Core ML inference.
