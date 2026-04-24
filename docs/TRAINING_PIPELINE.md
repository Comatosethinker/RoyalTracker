# Training Pipeline

RoyalTracker should use three related codebases or product surfaces:

## 1. Public macOS App

Purpose:

- screen capture from a Mac window or mirrored phone
- suspicious event detection
- manual labels for candidate frames
- export training samples
- debug recognition behavior

Output:

```text
~/Documents/RoyalTracker/Captures/session-YYYYMMDD-HHMMSS/
  event-001.png
  event-002.png
  labels.jsonl
```

The public repository can contain the app code and sample schemas, but exported user captures should stay local unless the user explicitly contributes them.

## 2. Public iOS App

Purpose:

- user-authorized ReplayKit screen capture
- lightweight local event detection
- eventual on-device inference
- optional contribution export

The iOS app should consume released model files from the training repository, but it should not contain private datasets or raw training notebooks.

## 3. Private Lab Repository

Recommended private repository:

```text
Comatosethinker/RoyalTracker-Lab
```

Purpose:

- store private raw captures
- clean and deduplicate labels
- train models
- evaluate model versions
- export release artifacts for the public apps

Suggested layout:

```text
RoyalTracker-Lab/
  datasets/
    raw/
    reviewed/
    splits/
  notebooks/
  training/
  models/
    candidate-detector/
    card-classifier/
  reports/
  exports/
    RoyalTrackerModel-v0.1.mlpackage
    RoyalTrackerModel-v0.1.mlmodel
    RoyalTrackerModel-v0.1.json
```

## Label Schema

Each exported line from `labels.jsonl` should follow this shape:

```json
{
  "schema_version": 1,
  "file_name": "event-001.png",
  "timestamp": "2026-04-24T12:00:00Z",
  "match_elapsed": 73.2,
  "movement_score": 0.27,
  "label_kind": "真实出牌",
  "is_card_play": true,
  "card_id": "witch",
  "notes": "clear deployment frame"
}
```

Negative examples are required. Useful negative labels include:

- `误报`
- `召唤/产物`
- `克隆效果`

These examples teach the model and rule layer not to treat every new battlefield unit as a new card play.

## First Training Milestone

Do not train on every card at first. Start with 10-20 high-signal cards:

- fireball
- arrows
- log
- hog-rider
- balloon
- giant
- pekka
- x-bow
- mortar
- inferno-tower

Target:

- 1,000-3,000 labeled events
- balanced positive and negative examples
- simple image classifier or frame-burst classifier
- evaluation report with per-card precision and recall

## Release Flow

```text
macOS/iOS capture
-> export labeled sessions
-> import into private Lab
-> clean and split data
-> train model
-> evaluate
-> export Core ML model
-> copy model artifact into public app release
-> publish app update
```

Model artifacts can be public if they do not contain raw user data. Raw captures should remain private or opt-in only.
