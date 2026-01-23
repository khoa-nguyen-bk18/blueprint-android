#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

SESSION="$(ls -1t .ai/sessions/*.md | head -n 1)"
./tools/ai-context.sh

echo ""
echo "===== COPY INTO AI ====="
cat .ai/context/AI_CONTEXT.md
echo ""
echo "TASK: Resume from last session."
echo "Follow Next Steps. Respect approved scope."
