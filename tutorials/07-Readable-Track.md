# 07 — Readable Track (Anchors + ToC)

Tell Codex:
```
Implement readable export:
- Parse text via PDFKit page.string
- detectHeading → Heading nodes; others as Paragraph
- index.md with collapsible ToC (H1..H3) and explicit <a id="..."> anchors
- NO paraphrasing

Plan → build → run → export.
Commit: "feat(readable): index.md with anchors + ToC".
```
**Verify**: ToC links jump correctly in GitHub preview.
