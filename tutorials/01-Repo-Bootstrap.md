# 01 — Repo Bootstrap (you already have `.git/`)

From the repo root:
```bash
unzip midi2-reader-staged-usable.zip
git add -A
git commit -m "feat: staged workspace (workspace/, reference/, tutorials/, scripts/)"
git push
```

Then switch to the working area:
```bash
cd workspace
swift build -c release
swift run MIDI2SpecReader
```
Expected: a minimal window with “MIDI2 Reader — Starter Shell”.
