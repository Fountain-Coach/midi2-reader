# 06 — Facsimile Track (Source of Truth)

Tell Codex:
```
Implement baseline facsimile export:
- Render each page to PNG at ~220 DPI into Artifacts/<DOCID>/facsimile/
- Generate facsimile.html listing pages
- "Export Site…" menu to choose target folder; write outputs there

Plan → build → run → export.
Commit: "feat(facsimile): page renders + facsimile.html".
```
**Verify**: PNGs and HTML appear; images match the PDF pages.
