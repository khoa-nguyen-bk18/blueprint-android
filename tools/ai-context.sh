#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT=".ai/context/AI_CONTEXT.md"
mkdir -p .ai/context

emit() {
  echo "### $1"
  echo '```'
  sed -n '1,260p' "$1"
  echo '```'
  echo ""
}

{
  echo "# AI Context Pack"
  echo ""
  echo "- Repo: $(basename "$ROOT")"
  echo "- Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "- Commit: $(git rev-parse --short HEAD)"
  echo ""

  echo "## AI Protocol"
  emit ".ai/prompts/MASTER_PROMPT.md"

  echo "## Project Rules"
  emit "docs/ai/AI_RULES.md"
  emit "docs/ai/PROJECT_MAP.md"
  emit "docs/ai/DEFINITION_OF_DONE.md"
  emit "docs/ai/GOLDEN_EXAMPLES.md"

  echo "## Latest Session (if any)"
  last="$(ls -1t .ai/sessions/*.md 2>/dev/null | head -n 1 || true)"
  if [ -n "$last" ]; then
    emit "$last"
  else
    echo "_No session yet_"
  fi

  echo "## Git Status"
  echo '```'
  git status --porcelain
  echo '```'
} > "$OUT"

echo "✅ AI context generated: $OUT"
