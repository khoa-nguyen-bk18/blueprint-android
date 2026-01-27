#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# Generate context
./tools/ai-context.sh

# Create the prompt
PROMPT="$(cat .ai/context/AI_CONTEXT.md)

---

TASK: Resume from last session.
Follow Next Steps. Respect approved scope."

echo "🚀 Resuming session with Gemini..."
echo ""

# Launch Gemini with the prompt
gemini -p "$PROMPT"
