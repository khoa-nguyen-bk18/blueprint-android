#!/usr/bin/env bash
set -euo pipefail

TBD="TBD"

need_cmd() { command -v "$1" >/dev/null 2>&1; }

if ! need_cmd gum; then
  echo "gum not found."
  echo "Install on Termux: pkg install gum"
  exit 1
fi

slugify() {
  # lowercase -> keep alnum/space/- -> spaces to dashes -> trim dashes
  echo "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-z0-9 -]//g' \
    | sed 's/[[:space:]]\+/-/g' \
    | sed 's/-\{2,\}/-/g' \
    | sed 's/^-//; s/-$//'
}

bullets() {
  local text="${1:-}"
  local trimmed
  trimmed="$(echo "$text" | sed '/^[[:space:]]*$/d')"
  if [[ -z "$trimmed" ]]; then
    echo "- $TBD"
    return
  fi
  while IFS= read -r line; do
    [[ -z "${line//[[:space:]]/}" ]] && continue
    echo "- $line"
  done <<< "$trimmed"
}

val_or_tbd() {
  local v="${1:-}"
  if [[ -z "${v//[[:space:]]/}" ]]; then
    echo "$TBD"
  else
    echo "$v"
  fi
}

section_title() {
  gum style --bold --padding "0 0" --margin "1 0" "$1"
}

# -----------------------------
# Wizard start
# -----------------------------
gum style --bold --border rounded --padding "1 2" "Feature Spec Wizard (BA + UX) → Markdown"

FEATURE_NAME="$(gum input --prompt "Feature name: " --placeholder "e.g., Local Login Validation")"
[[ -z "${FEATURE_NAME//[[:space:]]/}" ]] && { echo "Feature name is required."; exit 1; }

SLUG="$(slugify "$FEATURE_NAME")"
DATE_YMD="$(date +%Y-%m-%d)"
DATE_PREFIX="$(date +%Y%m%d)"
VERSION="$(gum input --prompt "Spec version: " --value "0.1" --placeholder "e.g., 0.1")"

PRIORITY="$(gum choose "P0 (must)" "P1 (should)" "P2 (nice)" "P3 (later)")"

section_title "A) Overview"
SUMMARY="$(gum input --prompt "One-line summary: " --placeholder "What is this feature?")"
GOAL="$(gum input --prompt "Goal (user outcome): " --placeholder "User can ...")"
BUSINESS_VALUE="$(gum input --prompt "Business value: " --placeholder "Why does the business want this?")"

NON_GOALS="$(gum write --placeholder "Non-goals (one per line). ESC or Ctrl+D to finish." --width 80 --height 8 || true)"

section_title "B) Users & permissions"
PRIMARY_USERS="$(gum write --placeholder "Primary users (one per line)" --width 80 --height 6 || true)"
SECONDARY_USERS="$(gum write --placeholder "Secondary users (one per line)" --width 80 --height 6 || true)"

PERMISSION_RULES="$(gum write --placeholder "Permission rules (who can view/do this). ESC/Ctrl+D to finish." --width 80 --height 8 || true)"
PRECONDITIONS="$(gum write --placeholder "Preconditions (login? verified? existing data?)" --width 80 --height 6 || true)"

section_title "C) UX/UI behavior"
SCREENS="$(gum write --placeholder "Screens involved (one per line, e.g., LoginScreen)" --width 80 --height 6 || true)"
ENTRY_POINTS="$(gum write --placeholder "Entry points (one per line)" --width 80 --height 6 || true)"

EXIT_SUCCESS="$(gum input --prompt "On success, go to: " --placeholder "e.g., HomeScreen")"
EXIT_CANCEL_BACK="$(gum input --prompt "On cancel/back, do: " --placeholder "e.g., discard changes and return")"
DRAFT_RULE="$(gum input --prompt "If user leaves mid-way: draft rule: " --placeholder "e.g., save draft locally / discard")"

section_title "Inputs (fields)"
FIELDS_MD=""
while true; do
  FIELD_NAME="$(gum input --prompt "Field name (blank to finish): " --placeholder "e.g., Email")" || true
  [[ -z "${FIELD_NAME//[[:space:]]/}" ]] && break

  FIELD_REQUIRED="$(gum choose "yes" "no")"
  FIELD_CONSTRAINTS="$(gum input --prompt "Format/constraints: " --placeholder "e.g., max 50 chars, email regex")" || true
  FIELD_TRIM="$(gum input --prompt "Trim rules: " --placeholder "e.g., trim spaces, collapse whitespace")" || true
  FIELD_DEFAULT="$(gum input --prompt "Default value: " --placeholder "e.g., empty")" || true
  FIELD_VALIDATION_MSG="$(gum input --prompt "Validation message (exact text): " --placeholder "e.g., \"Email is required\"")" || true

  FIELDS_MD+="- Field name: **$(val_or_tbd "$FIELD_NAME")**"$'\n'
  FIELDS_MD+="  - Required: $(val_or_tbd "$FIELD_REQUIRED")"$'\n'
  FIELDS_MD+="  - Format/constraints: $(val_or_tbd "$FIELD_CONSTRAINTS")"$'\n'
  FIELDS_MD+="  - Trim rules: $(val_or_tbd "$FIELD_TRIM")"$'\n'
  FIELDS_MD+="  - Default value: $(val_or_tbd "$FIELD_DEFAULT")"$'\n'
  FIELDS_MD+="  - Validation message: $(val_or_tbd "$FIELD_VALIDATION_MSG")"$'\n'
done
[[ -z "${FIELDS_MD//[[:space:]]/}" ]] && FIELDS_MD="- $TBD"$'\n'

section_title "Actions & feedback"
PRIMARY_CTA="$(gum input --prompt "Primary CTA (button text): " --placeholder "e.g., Continue")"
PRIMARY_CTA_ENABLED="$(gum input --prompt "Primary CTA enabled when: " --placeholder "e.g., all required fields valid")"
PREVENT_DOUBLE_SUBMIT="$(gum input --prompt "Prevent double submit? (how): " --placeholder "e.g., disable CTA while loading")"
SECONDARY_ACTIONS="$(gum input --prompt "Secondary actions: " --placeholder "e.g., Cancel, Forgot password")"

LOADING_INDICATOR="$(gum input --prompt "Loading indicator location: " --placeholder "e.g., on CTA, full-screen overlay")"
ERROR_STYLE="$(gum choose "inline" "banner" "snackbar" "dialog")"
SUCCESS_FEEDBACK="$(gum input --prompt "Success feedback (text/placement): " --placeholder "e.g., snackbar \"Saved\" then navigate")"

EMPTY_STATES="$(gum write --placeholder "Empty states (one per line: when -> what shown -> CTA)" --width 80 --height 6 || true)"

section_title "D) State model"
STATE_MD=""
while true; do
  ST_NAME="$(gum input --prompt "State name (blank to finish): " --placeholder "e.g., Idle")" || true
  [[ -z "${ST_NAME//[[:space:]]/}" ]] && break
  ST_DESC="$(gum input --prompt "What UI does in this state: " --placeholder "e.g., CTA disabled, show form")" || true
  STATE_MD+="- **$(val_or_tbd "$ST_NAME")**: $(val_or_tbd "$ST_DESC")"$'\n'
done
[[ -z "${STATE_MD//[[:space:]]/}" ]] && STATE_MD="- $TBD"$'\n'

section_title "E) Functional requirements"
FR="$(gum write --placeholder "Functional requirements (one per line, each testable)" --width 80 --height 8 || true)"

section_title "F) Business rules"
VR="$(gum write --placeholder "Validation rules (one per line: VR-#: rule + message + example)" --width 80 --height 8 || true)"
DR="$(gum write --placeholder "Decision rules (one per line: DR-#: If <cond> then <result> + example)" --width 80 --height 8 || true)"
ORR="$(gum write --placeholder "Ordering/dedup/idempotency rules (one per line: OR-#: ...)" --width 80 --height 6 || true)"

section_title "G) Data"
DATA_INPUTS="$(gum write --placeholder "Data inputs used (one per line)" --width 80 --height 6 || true)"
DATA_OUTPUTS="$(gum write --placeholder "Data outputs shown to user (one per line)" --width 80 --height 6 || true)"
DATA_SAVED="$(gum write --placeholder "What must be saved (and when) (one per line)" --width 80 --height 6 || true)"
DATA_NOT_SAVED="$(gum write --placeholder "What must NOT be saved/logged (PII/security) (one per line)" --width 80 --height 6 || true)"
RETENTION="$(gum input --prompt "Retention (if relevant): " --placeholder "e.g., keep drafts 7 days")"

section_title "H) Error handling"
EH="$(gum write --placeholder "Error scenarios & recovery (one per line: EH-#: scenario -> message -> recovery)" --width 80 --height 8 || true)"

section_title "I) Acceptance criteria"
AC="$(gum write --placeholder "Acceptance criteria (one per line: Given/When/Then)" --width 80 --height 10 || true)"

section_title "J) Android/Kotlin notes"
ANDROID_NOTES="$(gum write --placeholder "Android notes (optional): back handling, keyboard, offline, accessibility" --width 80 --height 8 || true)"

section_title "K) Tracking / audit"
TRACK_EVENTS=false
EVENTS=""
if gum confirm "Track analytics events?"; then
  TRACK_EVENTS=true
  EVENTS="$(gum write --placeholder "Events list (one per line: name + trigger + properties)" --width 80 --height 8 || true)"
fi

section_title "L) Open questions"
OPEN_Q="$(gum write --placeholder "Open questions (one per line)" --width 80 --height 8 || true)"

# -----------------------------
# Write Markdown
# -----------------------------
OUT_DIR="specs"
mkdir -p "$OUT_DIR"
OUT_PATH="${OUT_DIR}/${DATE_PREFIX}-${SLUG}.md"

cat > "$OUT_PATH" <<EOF
# Feature Spec — ${FEATURE_NAME}

- Date: ${DATE_YMD}
- Version: $(val_or_tbd "$VERSION")
- Priority: $(val_or_tbd "$PRIORITY")
- Status: Draft

---

## A) Overview
- One-line summary: $(val_or_tbd "$SUMMARY")
- Goal (user outcome): $(val_or_tbd "$GOAL")
- Business value: $(val_or_tbd "$BUSINESS_VALUE")

### Non-goals (NOT in this version)
$(bullets "$NON_GOALS")

---

## B) Users & permissions
### Primary user(s)
$(bullets "$PRIMARY_USERS")

### Secondary user(s)
$(bullets "$SECONDARY_USERS")

### Permission rules (who can view/do this)
$(val_or_tbd "$PERMISSION_RULES")

### Preconditions
$(val_or_tbd "$PRECONDITIONS")

---

## C) UX/UI behavior (behavioral, not pixel-perfect)

### Screens involved
$(bullets "$SCREENS")

### Entry points
$(bullets "$ENTRY_POINTS")

### Exit points
- On success, go to: $(val_or_tbd "$EXIT_SUCCESS")
- On cancel/back, do: $(val_or_tbd "$EXIT_CANCEL_BACK")
- If user leaves mid-way: $(val_or_tbd "$DRAFT_RULE")

### Inputs
$FIELDS_MD

### Actions
- Primary CTA: $(val_or_tbd "$PRIMARY_CTA")
- Primary CTA enabled when: $(val_or_tbd "$PRIMARY_CTA_ENABLED")
- Prevent double submit?: $(val_or_tbd "$PREVENT_DOUBLE_SUBMIT")
- Secondary actions: $(val_or_tbd "$SECONDARY_ACTIONS")

### Feedback placement
- Loading indicator location: $(val_or_tbd "$LOADING_INDICATOR")
- Error display style: $(val_or_tbd "$ERROR_STYLE")
- Success feedback: $(val_or_tbd "$SUCCESS_FEEDBACK")

### Empty states (if applicable)
$(bullets "$EMPTY_STATES")

---

## D) State model (must be deterministic)
$STATE_MD

---

## E) Functional requirements (SHALL)
$(bullets "$FR")

---

## F) Business rules (decision logic + examples)

### Validation rules
$(bullets "$VR")

### Decision rules (if/then)
$(bullets "$DR")

### Ordering / dedup / idempotency rules
$(bullets "$ORR")

---

## G) Data (business view)

### Data inputs used (from user/system)
$(bullets "$DATA_INPUTS")

### Data outputs shown to user
$(bullets "$DATA_OUTPUTS")

### What must be saved (and when)
$(bullets "$DATA_SAVED")

### What must NOT be saved/logged (PII/security)
$(bullets "$DATA_NOT_SAVED")

### Retention (if relevant)
$(val_or_tbd "$RETENTION")

---

## H) Error scenarios & recovery
$(bullets "$EH")

---

## I) Acceptance criteria (Given/When/Then)
$(bullets "$AC")

---

## J) Android/Kotlin notes (optional but recommended)
$(val_or_tbd "$ANDROID_NOTES")

---

## K) Tracking / audit (optional)
- Track events?: $([[ "$TRACK_EVENTS" == "true" ]] && echo "yes" || echo "no")

### Events list
$(bullets "$EVENTS")

---

## L) Open questions
$(bullets "$OPEN_Q")
EOF

gum style --bold "✅ Generated: $OUT_PATH"

if gum confirm "Open now in nano?"; then
  nano "$OUT_PATH"
fi
