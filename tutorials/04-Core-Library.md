# 04 — Core Library (inside `workspace/`)

Tell Codex:
```
Create SwiftPM structure with:
- Midi2Core (library): Span/Node/SpecDoc models, slugify, detectHeading (numbered headings).
- MIDI2SpecReader (SwiftUI app): opens, later exports.
- Unit tests for slugify and detectHeading.

Plan first; then run swift build and swift test.
Commit locally: "feat(core): models + slug/heading + tests".
```
**Expected**: tests pass; code remains strictly under `workspace/`.
