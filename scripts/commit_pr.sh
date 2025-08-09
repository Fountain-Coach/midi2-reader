#!/usr/bin/env bash
set -euo pipefail
TS="$(date -u +%Y%m%d-%H%M%SZ)"
BR="ci/midi2-reader-${TS}"
BASE="${BASE_BRANCH:-main}"

git fetch --all --prune || true
git checkout -B "$BR"
git add Artifacts/** || true
git commit -m "chore(reader): generated artifacts (${TS})" || true
git push -u origin "$BR"

gh pr create --base "$BASE" --head "$BR"   --title "MIDI2 Reader: generated artifacts (${TS})"   --body "See Artifacts/."
