#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

FEATURE="${1:-}"
if [ -z "$FEATURE" ]; then
  echo "Usage: ai-start-copilot <feature-name>"
  exit 1
fi

DATE="$(date +%Y-%m-%d)"
SESSION=".ai/sessions/${DATE}__${FEATURE}.md"

mkdir -p .ai/sessions
cp .ai/sessions/SESSION_TEMPLATE.md "$SESSION"

# Generate context
./tools/ai-context.sh

# Create the prompt
PROMPT="$(cat .ai/context/AI_CONTEXT.md)

---

TASK: Start feature '$FEATURE'.
First summarize rules. Then Abstract → Flow → UI → Change Contract.
Do NOT write code before I reply APPROVE_CONTRACT."

echo "🚀 Launching GitHub Copilot with AI context..."
echo ""

# Launch Copilot in interactive mode with the prompt
copilot --allow-all-tools -i "$PROMPT"
