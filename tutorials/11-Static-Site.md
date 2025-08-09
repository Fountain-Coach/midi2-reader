# 11 — Static Site Export (both tracks)

## What to say to Codex
```
Add "Export Site…" (both tracks):
- For each opened PDF, write artifacts/<DOCID>/:
  - facsimile/ (PNGs + facsimile.html + spans json if needed)
  - index.md (readable)
  - specdoc.json (nodes + spans + page sizes)
- Root artifacts/README.md lists all docs.
- Add provenance.json with sha256 of PDF and counts.
- Add QA.md with coverage stats (extracted chars / PDF chars).

Commit: "feat(export): two-track static site with provenance + QA"
```
## Expected results
- A navigable artifacts/ tree per doc with QA and provenance.
