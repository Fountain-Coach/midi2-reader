# 03 — First Commit (let Codex do it)

## What to say to Codex (copy/paste)
Run in repo root: `codex` then paste:

```
Create a minimal SwiftPM workspace for a macOS app + core library:

Structure:
- Package.swift (macOS v13)
- Sources/Midi2Core/ (library: models, slugify, heading detector)
- Sources/MIDI2SpecReader/ (SwiftUI app executable)
- .github/PULL_REQUEST_TEMPLATE.md
- scripts/commit_pr.sh
- .gitignore (ignore .build, .DS_Store, inputs/*.pdf)
- README.md (goals & how to build)

Rules:
- Ask before running commands; show your plan first.
- After files are created, run: git add . && git commit -m "chore: initial scaffold"
```
## Expected results
- Files appear, commit created.

## Verify
```bash
git log --oneline -1
# shows 'chore: initial scaffold'
```
