Perfect 👍
You already have the core brain of the system. Now we’ll wire it so that:

AI can load those rules automatically

sessions are recoverable

a “new guy” can start or resume work with one command


I’ll tell you exactly what to do next, in order, with why for each step.


---

Where you are now (current state)

You have ✅

docs/ai/
├─ AI_RULES.md
├─ PROJECT_MAP.md
├─ DEFINITION_OF_DONE.md
└─ GOLDEN_EXAMPLES.md

This means:

You have governance

You do not yet have execution + memory


Next steps are about execution + memory.


---

Step 1 — Create the AI working directories (5 minutes)

From repo root, run:

mkdir -p tools
mkdir -p .ai/prompts
mkdir -p .ai/sessions
mkdir -p .ai/context

Why:

.ai/prompts → how AI behaves

.ai/sessions → save/restore work

.ai/context → generated preload file

tools → control plane



---

Step 2 — Add the MASTER PROMPT (this controls AI behavior)

Create this file:

.ai/prompts/MASTER_PROMPT.md

You are my Android coding agent.

STRICT PROTOCOL:
1) Read docs/ai/* and summarize rules + architecture in 8–12 bullets.
2) Produce: Abstract → Flow → UI plan.
3) Produce a Change Contract listing exact files to modify/create and must-pass commands.
4) DO NOT write code until I reply APPROVE_CONTRACT.
5) Prefer modifying existing code before creating new files.
6) Work in small slices; after each slice, validate via tools/check-fast.sh.
7) Do not touch files outside the approved Change Contract / allowlist.

Why:

This is the behavior lock

Every AI session starts from this



---

Step 3 — Add session memory (so you can “catch up” later)

Create a session template:

.ai/sessions/SESSION_TEMPLATE.md

# Session: YYYY-MM-DD — Feature: <name>

## Goal
-

## Current Status
- Phase: Kickoff | Abstract | Flow | UI | Contract Approved | Slice N | Done
- Last checkpoint commit:

## Approved Change Contract
- (pending)

## Work Done
-

## Next Steps
1)
2)

## Resume Prompt
Read docs/ai/*.
Use this session snapshot.
Resume from Next Steps.
Do not touch files outside approved scope.

Why:

This is your save game

AI + humans read the same truth



---

Step 4 — Create the context loader script (MOST IMPORTANT)

This is the missing piece:
one command → AI knows everything

tools/ai-context.sh

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

Make it executable:

chmod +x tools/ai-context.sh

Why:

This script is the bridge between repo and AI

A new guy does NOT need to know anything



---

Step 5 — Create “start” and “resume” commands

Start a new feature

tools/ai-start.sh

#!/usr/bin/env bash
set -euo pipefail

FEATURE="$1"
[ -z "$FEATURE" ] && echo "Usage: ai-start <feature-name>" && exit 1

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


---

Resume last session

tools/ai-resume.sh

#!/usr/bin/env bash
set -euo pipefail

SESSION="$(ls -1t .ai/sessions/*.md | head -n 1)"
./tools/ai-context.sh

echo ""
echo "===== COPY INTO AI ====="
cat .ai/context/AI_CONTEXT.md
echo ""
echo "TASK: Resume from last session."
echo "Follow Next Steps. Respect approved scope."

Make both executable:

chmod +x tools/ai-start.sh tools/ai-resume.sh


---

Step 6 — (Optional but recommended) Add shell aliases

alias ai-start="./tools/ai-start.sh"
alias ai-resume="./tools/ai-resume.sh"

Now your workflow becomes:

ai-start onboarding-survey
# or
ai-resume


---

What you should do RIGHT NOW (exact order)

1. ✅ You already have docs/ai/*


2. ➜ Create .ai/prompts/MASTER_PROMPT.md


3. ➜ Create .ai/sessions/SESSION_TEMPLATE.md


4. ➜ Create tools/ai-context.sh


5. ➜ Create tools/ai-start.sh and tools/ai-resume.sh


6. ➜ Run ai-start <feature>



At that point:

AI always loads your rules

Sessions are recoverable

You can leave for a week and resume safely

A new team member can onboard in 5 minutes



---

If you want, next I can:

integrate this with Copilot CLI directly

add allowlist enforcement

adapt it to Compose + MVVM + Koin/Hilt

create a Makefile / justfile version


Just tell me the next step you want.
