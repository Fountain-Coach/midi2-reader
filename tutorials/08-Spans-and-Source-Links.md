# 08 — Real Spans + 📎 Source Links

Tell Codex:
```
Compute real bounding boxes for each node:
- Use PDFSelection to get .bounds in PDF points → Span.bbox
- Span.sha256 = SHA-256 of the node text (UTF-8)
- After each heading/paragraph/table, append [📎 source](./facsimile/facsimile.html#pN-xX-yY-wW-hH)
- Make facsimile.html scroll to fragment ids pN-xX-yY-wW-hH

Plan → build → run → export.
Commit: "feat(spans): bboxes + facsimile deep-links".
```
**Verify**: Clicking 📎 jumps into the correct page region.
