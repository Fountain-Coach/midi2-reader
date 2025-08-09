# 05 — Implement Midi2Core (models, slugify, heading)

## What to say to Codex
```
Implement Midi2Core:

- Models: Span(page,bbox[],confidence,sha256?), Node(kind,text,attrs,spans), SpecDoc(pages,nodes,sha256)
- Slugify: keep numbers; replace dots between digits with hyphens; strip non-alnum; collapse spaces.
- detectHeading: ^((?:\d+\.)+\d+|\d+)\s+(.+)$

Add unit tests for slugify and detectHeading.
Add 'swift test' to the default pipeline; fix until green.
Commit: "feat(core): models + slug/heading + tests"
```
## Expected results
- Library compiles; tests pass.

## Verify
```bash
swift test
```
