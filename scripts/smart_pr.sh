#!/usr/bin/env bash
set -euo pipefail
TS="$(date -u +%Y%m%d-%H%M%SZ)"
BR="ci/midi2-reader-${TS}"
BASE="${BASE_BRANCH:-main}"

git fetch --all --prune || true
git checkout -B "$BR"
git add Artifacts/** || true
git commit -m "MIDI2 Reader: export site (${TS})" || true

BODY="PR_BODY.md"
{
  echo "## Summary"
  echo "Export MIDI 2.0 specs (facsimile + readable) with provenance and QA."
  echo ""
  echo "## Change Stats"
  echo '```'
  git diff --staged --numstat || true
  echo '```'
  echo ""
  echo "## Files Changed"
  echo '```'
  git diff --staged --name-status | sed 's/^/ - /' || true
  echo '```'
  echo ""
  echo "## Generated indexes"
  find Artifacts -name index.md -type f 2>/dev/null | sed 's#^#- #' || true
  echo ""
  if [ -f Artifacts/QA.md ]; then
    echo "## QA"
    cat Artifacts/QA.md
  fi
} > "$BODY"

git push -u origin "$BR"
gh pr create --base "$BASE" --head "$BR"   --title "MIDI2 Reader: export site (${TS})"   --body-file "$BODY"
