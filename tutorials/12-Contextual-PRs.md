# 12 — Contextual PRs via `gh`

## What to say to Codex
```
Add scripts/smart_pr.sh:
- Build PR_BODY.md with:
  - Summary, numstat, name-status
  - List of generated index.md files
  - Append QA.md (if exists)
- Create branch ci/midi2-$(date -u +%Y%m%d-%H%M%SZ), push, and:
  gh pr create --base main --head "$BR" --title "MIDI2 Reader: site export" --body-file PR_BODY.md

Then run it after export.

Commit: "chore(pr): contextual PR script"
```
## Expected results
- PR opens with a useful body and links.
