# 15 — Iteration Prompt Template (paste into Codex)

```
Plan first:
1) Print a numbered plan with file paths & diffs you will make.
2) Wait for my OK before edits or commands.

Then execute:
- Make the changes.
- Run: swift build -c release
- If it fails, quote each error and apply minimal fixes; re-run until green (max 3 cycles).
- Run the app; perform the export pipeline.
- Generate/update artifacts/QA.md and provenance.json.
- Stage and update the PR with scripts/smart_pr.sh.

Constraints:
- Work ONLY inside this repo. Ask before running commands.
- Preserve normative wording; do not paraphrase.
- Keep anchors stable; ToC is collapsible (H1..H3).
- Deep-link every node to facsimile with [📎 source].
```
