# 14 — Strict Mode & Tests

## What to say to Codex
```
Add a --strict flag to export:
- If any page has zero extractable text or any node lacks spans, exit non-zero.
- Write strict_report.json with counts (pages, nodes, spans, missing).

Add XCTest target:
- slugify and heading regex unit tests
- link integrity test: all ToC links resolve to <a id>, and 📎 links hit a facsimile element.

Commit: "feat(strict): strict mode + XCTest coverage"
```
## Expected results
- Failing conditions stop export in strict mode.
- `swift test` passes.
