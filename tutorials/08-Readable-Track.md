# 08 — Readable Track Skeleton (anchors + ToC)

## What to say to Codex
```
Implement a readable export for each PDF:
- Parse page text via PDFKit.page.string
- Split into lines; classify numbered headings via detectHeading → Heading nodes else Paragraph.
- Write artifacts/<DOCID>/index.md with:
  - a collapsible ToC (H1..H3),
  - explicit <a id="..."></a> anchors per heading,
  - exact text paragraphs (no paraphrase).

Commit: "feat(readable): index.md with collapsible ToC + explicit anchors"
```
## Expected results
- index.md exists, readable on GitHub.

## Verify
Open index.md in GitHub preview; ToC links should jump correctly.
