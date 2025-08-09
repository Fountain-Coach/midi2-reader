# 10 — Static Site (Both Tracks + Provenance + QA)

Tell Codex:
```
Export for each opened PDF:
- facsimile/ (PNGs + facsimile.html)
- index.md (readable)
- specdoc.json (nodes + spans + page sizes)
- provenance.json (sha256, counts)
- QA.md (coverage stats; link integrity)

Plan → build → run → export.
Commit: "feat(export): static site with provenance + QA".
```
**Verify**: artifacts tree per doc with provenance & QA present.
