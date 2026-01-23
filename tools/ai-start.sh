#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

FEATURE="${1:-}"
if [ -z "$FEATURE" ]; then
  echo "Usage: ai-start <feature-name>"
  exit 1
fi

DATE="$(date +%Y-%m-%d)"
SESSION=".ai/sessions/${DATE}__${FEATURE}.md"

mkdir -p .ai/sessions
cp .ai/sessions/SESSION_TEMPLATE.md "$SESSION"

./tools/ai-context.sh

echo ""
echo "===== COPY INTO AI ====="
cat .ai/context/AI_CONTEXT.md
echo ""
echo "TASK: Start feature '$FEATURE'."
echo "First summarize rules. Then Abstract → Flow → UI → Change Contract."
echo "Do NOT write code before I reply APPROVE_CONTRACT."
