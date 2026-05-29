# Great Tips Game Sample

A Flutter sample app that demonstrates a local JSON-driven implementation of the first-shift framework for **Great Tips Game**.

## What is included

- Offline content loading from `assets/content/shifts/shift_1.json`.
- Riverpod state management around a reusable game controller.
- Tip Meter scoring with hard boundaries at 0 and 100.
- Multiple-choice scenes with instant feedback, reinforcement copy, notebook unlocks, and coaching flags.
- A timed scene with a 30-second countdown and timeout auto-submit behavior.
- A local Manager Dashboard tab with progress, score, coaching flags, and notebook unlocks.

## Run locally

```bash
flutter pub get
flutter run
```

## Validate sample content

```bash
python3 -m json.tool assets/content/shifts/shift_1.json >/tmp/shift_1.validated.json
```
