#!/usr/bin/env bash
set -euo pipefail

ALLOWLIST_FILE=".ai/allowlist.txt"

if [ ! -f "$ALLOWLIST_FILE" ]; then
  echo "Missing $ALLOWLIST_FILE. Generate it from the approved Change Contract."
  exit 1
fi

changed="$(git diff --name-only --diff-filter=ACMR)"

if [ -z "$changed" ]; then
  echo "No changes detected."
  exit 0
fi

violations=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if ! grep -Fxq "$f" "$ALLOWLIST_FILE"; then
    echo "❌ File not in allowlist: $f"
    violations=1
  fi
done <<< "$changed"

if [ "$violations" -ne 0 ]; then
  echo ""
  echo "Fix: update Change Contract + allowlist, or revert unexpected files."
  exit 1
fi

echo "✅ All changed files are allowed."
