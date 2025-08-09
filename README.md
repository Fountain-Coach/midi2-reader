# MIDI2 Reader — STAGED Workspace (Usable Final)

This pack is ready to drop into a repo that currently has only `.git/` left.

**Layout**
- `workspace/` — your live project (Codex edits live here). Starts as a minimal SwiftPM app.
- `reference/`
  - `starter/` — clean reset snapshot
  - `final/` — a working reference app snapshot (read-only)
- `tutorials/` — rewritten lessons tailored to the staged layout
- `scripts/` — helper scripts to switch `workspace/` between starter/final

**Quick apply**
```bash
# at your repo root (the directory that contains .git/)
unzip midi2-reader-staged-usable.zip
git add -A
git commit -m "feat: staged workspace (workspace/, reference/, tutorials/, scripts/)"
git push
```

**Get going**
```bash
cd workspace
swift build -c release
swift run MIDI2SpecReader             # starter UI

# optional: copy the working reference into workspace
../scripts/use-lesson.sh final
swift build -c release && swift run MIDI2SpecReader

# reset back to starter
../scripts/reset-workspace.sh
```

Use **Codex** only inside `workspace/` and paste `KICKOFF_FOR_CODEX.txt` from there.
