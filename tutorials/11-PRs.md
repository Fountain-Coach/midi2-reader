# 11 — Contextual PRs (`gh`)

Tell Codex:
```
Add scripts/smart_pr.sh:
- Generate PR_BODY.md from staged diff + list of generated index.md + QA.md
- Create branch ci/midi2-$(date -u +%Y%m%d-%H%M%SZ), push, gh pr create --body-file

Plan → implement → run after an export.
Commit: "chore(pr): contextual PR script".
```
**Verify**: PR opens with a descriptive body.
