#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")"/.. && pwd)"
LESSON="${1:-}"
if [ -z "${LESSON}" ]; then
  echo "Usage: scripts/use-lesson.sh <lesson-id | final | starter>"
  exit 1
fi
SRC="$HERE/reference/${LESSON}"
DST="$HERE/workspace"
if [ ! -d "$SRC" ]; then
  echo "Reference snapshot not found: $SRC" >&2
  exit 1
fi
echo "Copying $SRC → $DST ..."
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete --exclude='.git' "$SRC/" "$DST/"
else
  (cd "$SRC" && tar cf - .) | (cd "$DST" && tar xpf -)
  # simple cleanup of extra files
  find "$DST" -mindepth 1 -maxdepth 1 ! -name '.git' | while read -r p; do
    [ -e "$SRC/$(basename "$p")" ] || rm -rf "$p"
  done
fi
echo "Done. Your workspace now matches: reference/${LESSON}"
