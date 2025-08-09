# 10 — Tables (ruled grids → Markdown)

## What to say to Codex
```
Implement ruled-table detection:
- Use CGPDFScanner to collect path ops (m,l,re,S/s).
- Keep long straight horizontal/vertical segments; cluster to row/col guides (~2pt tol).
- For each cell rect, use PDFPage.selection(for:) to get text.
- Emit Markdown tables via tableToMarkdown.
- Attach a [📎 table source] link to the nearest cell region in facsimile.

Commit: "feat(tables): ruled grid extraction → Markdown"
```
## Expected results
- At least one table converts to Markdown correctly.

## Verify
Find a spec page with a visible grid; check output.
