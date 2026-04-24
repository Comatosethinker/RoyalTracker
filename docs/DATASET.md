# Dataset Plan

RoyalTracker needs a labeled event dataset before card recognition can become reliable.

## Unit of Data

The basic unit should be a short event clip or frame burst around a suspected play:

- 0.5-1.0 seconds before the event
- 0.8-1.5 seconds after the event
- cropped to the relevant battlefield or UI region when possible

Avoid storing complete match recordings unless the contributor explicitly chooses that.

## Labels

Recommended label fields:

```json
{
  "schema_version": 1,
  "card_id": "witch",
  "is_card_play": true,
  "is_summon_or_spawn": false,
  "is_clone_effect": false,
  "confidence": 1.0,
  "source": {
    "game_language": "zh-Hans",
    "platform": "macOS",
    "capture_resolution": "1920x1080",
    "arena_or_background": "unknown"
  },
  "notes": ""
}
```

## Negative Examples

Negative examples are important. Label these as `is_card_play: false`:

- Witch or Night Witch summoned units
- Furnace, Goblin Hut, Barbarian Hut, or Tombstone spawned units
- cloned units after Clone
- death spawns
- existing units crossing bridges
- tower shots and explosions that are not new cards

## Privacy

Default behavior should be local-only.

Before uploading any sample, the app should show exactly what will be shared. Contributors should be able to delete local captures and exported datasets.

## Training Scale

Suggested milestones:

- MVP: 1,000-3,000 labeled events across 20-30 high-signal cards
- usable: 20,000-50,000 labeled events across most common ladder cards
- mature: 100,000+ labeled events across arenas, resolutions, languages, and visual chaos
