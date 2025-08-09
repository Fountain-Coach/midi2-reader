# 13 — Strict Mode + Tests

Tell Codex:
```
Add --strict to export:
- Fail if pages have zero text or nodes lack spans
- strict_report.json with counts

Add XCTest:
- slugify, detectHeading
- link integrity: ToC links → <a id>, 📎 links → facsimile element

Plan → build → test.
Commit: "feat(strict): strict mode + XCTest".
```
**Verify**: `swift test` passes; strict-mode failures halt export.
