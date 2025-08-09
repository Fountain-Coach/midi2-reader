# 07 — Facsimile Track Skeleton (source of truth)

## What to say to Codex
```
Implement Facsimile skeleton (no overlays yet):
- For an opened PDF, render each page to PNG at ~220 DPI in Artifacts/<DOCID>/facsimile/page-<N>.png
- Write facsimile.html that lists page images (basic layout)
- Add an "Export Facsimile…" menu that asks for a folder and writes there.

Commit: "feat(facsimile): page renders + basic html index"
```
## Expected results
- Export writes PNGs + facsimile.html.

## Verify
Open the exported folder; you should see page-1.png, page-2.png, etc.
