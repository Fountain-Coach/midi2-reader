# 09 — Tables (ruled grids → Markdown)

Tell Codex:
```
Implement ruled-table extraction:
- CGPDFScanner: collect m/l/re and stroke ops
- Identify long H/V lines → cluster row/col guides (~2pt tolerance)
- For each cell rect, use PDFPage.selection(for:) → text
- tableToMarkdown for emission
- Add [📎 table source] to nearest cell region

Plan → build → run → export.
Commit: "feat(tables): ruled grid extraction → Markdown".
```
**Verify**: At least one grid page becomes a Markdown table.
