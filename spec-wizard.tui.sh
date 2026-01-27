#!/usr/bin/env bash
set -euo pipefail

TBD="N/A"

need_cmd() { command -v "$1" >/dev/null 2>&1; }

if ! need_cmd gum; then
  echo "gum not found."
  echo "Install on macOS: brew install gum"
  echo "Install on Termux: pkg install gum"
  exit 1
fi

if ! need_cmd fzf; then
  echo "fzf not found."
  echo "Install on macOS: brew install fzf"
  echo "Install on Linux: sudo apt install fzf"
  exit 1
fi

if ! need_cmd fzf; then
  echo "fzf not found."
  echo "Install on macOS: brew install fzf"
  echo "Install on Linux: sudo apt install fzf"
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

file_picker() {
  local prompt="${1:-Select file/folder}"
  local multi="${2:-false}"
  
  # Find all files and folders relative to current directory, exclude common build/cache dirs
  local find_cmd="find . -type f -o -type d"
  
  local selected
  if [[ "$multi" == "true" ]]; then
    # Multi-select with fzf
    selected=$(
      eval "$find_cmd" 2>/dev/null \
      | sed 's|^\./||' \
      | grep -v '^\\.git' \
      | grep -v '^build' \
      | grep -v '^node_modules' \
      | grep -v '^\\.gradle' \
      | sort \
      | fzf --multi \
            --prompt="$prompt (Tab to select multiple, Enter to confirm) > " \
            --preview='[[ -f {} ]] && head -50 {} || ls -la {}' \
            --preview-window=right:50%:wrap \
            --height=80% \
      || true
    )
  else
    # Single select with fzf
    selected=$(
      eval "$find_cmd" 2>/dev/null \
      | sed 's|^\./||' \
      | grep -v '^\\.git' \
      | grep -v '^build' \
      | grep -v '^node_modules' \
      | grep -v '^\\.gradle' \
      | sort \
      | fzf --prompt="$prompt > " \
            --preview='[[ -f {} ]] && head -50 {} || ls -la {}' \
            --preview-window=right:50%:wrap \
            --height=80% \
      || true
    )
  fi
  
  if [[ -z "$selected" ]]; then
    echo ""
    return
  fi
  
  # Convert to markdown links
  local result=""
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    local basename=$(basename "$path")
    if [[ -n "$result" ]]; then
      result+=", "
    fi
    result+="[${basename}](${path})"
  done <<< "$selected"
  
  echo "$result"
}

# Real-time input with # detection - launches fzf immediately
input_with_live_file_ref() {
  local prompt="$1"
  local placeholder="$2"
  
  echo ""
  gum style --bold "$prompt"
  gum style --italic "💡 Press Ctrl+F to launch fzf file picker. Press Enter when done."
  
  # Use readline for better input handling
  local result=""
  local temp_input
  
  # Set up Ctrl+F binding to launch fzf
  bind -x '"\C-f": _fzf_insert_file'
  
  # Function to insert file reference
  _fzf_insert_file() {
    local picked
    picked=$(file_picker "Select file/folder" "false")
    if [[ -n "$picked" ]]; then
      READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}${picked}${READLINE_LINE:$READLINE_POINT}"
      READLINE_POINT=$((READLINE_POINT + ${#picked}))
    fi
  }
  export -f _fzf_insert_file
  
  # Use read with readline support
  read -e -p "> " result
  
  # Clean up
  bind -r '\C-f' 2>/dev/null || true
  
  echo "$result"
}

prompt_with_file_ref() {
  local prompt="$1"
  local placeholder="$2"
  
  # Use real-time input handler
  local result
  result=$(input_with_live_file_ref "$prompt" "$placeholder")
  
  echo "$result"
}

write_with_file_ref() {
  local placeholder="$1"
  local width="${2:-80}"
  local height="${3:-8}"
  
  echo ""
  gum style --bold "Multi-line input (Ctrl+F for file picker, Ctrl+D to finish)"
  gum style --italic "💡 Type normally or press Ctrl+F to insert file references"
  echo ""
  
  # Use a temp file for multi-line editing
  local tmpfile=$(mktemp)
  
  # Set up Ctrl+F to work in editor
  export FCEDIT="${EDITOR:-nano}"
  
  # Simple multi-line input with vim/nano
  ${EDITOR:-nano} "$tmpfile" 2>/dev/null || cat > "$tmpfile"
  
  local result
  result=$(cat "$tmpfile")
  rm -f "$tmpfile"
  
  echo "$result"
}

# -----------------------------
# Wizard start
# -----------------------------
gum style --bold --border rounded --padding "1 2" "BA → Senior Dev Ticket Wizard"

# Template selection
TEMPLATE=$(gum choose \
  "1) New Feature Delivery" \
  "2) Change Request to Existing Feature" \
  "3) Bug & Correctness" \
  "4) Feasibility / Design Consultation" \
  "5) Integration & Dependencies" \
  "6) Data & Analytics Request" \
  "7) Quality / Performance / Reliability" \
  "8) Security / Privacy / Compliance" \
  "9) Release / Operations" \
  "10) Tech Debt / Maintainability" \
  "11) AI-era Workflow / Guardrails")

TEMPLATE_NUM=$(echo "$TEMPLATE" | cut -d')' -f1)

gum style --bold "Selected: $TEMPLATE"
echo ""
gum style --italic "💡 Tip: Press Ctrl+F while typing to launch fzf file picker"
echo ""

# Common ticket header fields
section_title "Ticket Header"
TITLE=$(prompt_with_file_ref "Title: " "e.g., Implement user login validation")
[[ -z "${TITLE//[[:space:]]/}" ]] && { echo "Title is required."; exit 1; }

SLUG="$(slugify "$TITLE")"
DATE_YMD="$(date +%Y-%m-%d)"
DATE_PREFIX="$(date +%Y%m%d)"

PRIORITY="$(gum choose "P0 (must)" "P1 (should)" "P2 (nice)" "P3 (later)")"
TARGET_RELEASE=$(prompt_with_file_ref "Target release/deadline: " "e.g., v2.5.0 or 2026-02-15")
OWNER_BA=$(gum input --prompt "Owner (BA): " --placeholder "Your name" || true)
STAKEHOLDERS=$(write_with_file_ref "Stakeholders (one per line). Use # to reference files." 80 5)

# Form-specific content based on template
case "$TEMPLATE_NUM" in
  "1")
    # Form 1: New Feature Delivery
    section_title "Problem & Goal"
    PROBLEM_STATEMENT=$(write_with_file_ref "Problem statement (current pain)" 80 6)
    GOAL=$(write_with_file_ref "Goal (what users can do after)" 80 6)
    BUSINESS_VALUE=$(write_with_file_ref "Business value" 80 6)
    NON_GOALS=$(write_with_file_ref "Non-goals (explicitly out of scope, one per line)" 80 8)
    
    section_title "Users & Permissions"
    PRIMARY_USERS=$(write_with_file_ref "Primary users (one per line)" 80 6)
    SECONDARY_USERS=$(write_with_file_ref "Secondary users (one per line)" 80 6)
    PERMISSION_RULES=$(write_with_file_ref "Permission rules" 80 8)
    PRECONDITIONS=$(write_with_file_ref "Preconditions (login, entitlement, required setup)" 80 6)
    
    section_title "UX / Behavior"
    SCREENS=$(write_with_file_ref "Screens involved (one per line)" 80 6)
    ENTRY_POINTS=$(write_with_file_ref "Entry points (one per line)" 80 6)
    EXIT_SUCCESS=$(prompt_with_file_ref "Exit: On success, go to: " "e.g., HomeScreen")
    EXIT_CANCEL=$(prompt_with_file_ref "Exit: On cancel/back, do: " "e.g., discard and return")
    DRAFT_RULE=$(prompt_with_file_ref "Draft/partial progress rule: " "save/discard/restore")
    INPUTS=$(write_with_file_ref "Inputs (fields + constraints + exact validation messages)" 80 10)
    ACTIONS=$(write_with_file_ref "Actions (CTA enabled rules + double-submit prevention)" 80 8)
    FEEDBACK=$(write_with_file_ref "Feedback (loading, success, error style, empty state)" 80 8)
    ACCESSIBILITY=$(write_with_file_ref "Accessibility/localization expectations (if any)" 80 6)
    
    section_title "Business Rules"
    VALIDATION_RULES=$(write_with_file_ref "Validation rules (with examples)" 80 10)
    DECISION_RULES=$(write_with_file_ref "Decision rules (if/then + examples)" 80 10)
    ORDERING_RULES=$(write_with_file_ref "Ordering/dedup/idempotency rules (if any)" 80 6)
    
    section_title "Data & Integrations"
    DATA_INPUTS=$(write_with_file_ref "Data inputs used" 80 6)
    DATA_OUTPUTS=$(write_with_file_ref "Data outputs shown" 80 6)
    DATA_SAVED=$(write_with_file_ref "What must be saved + when" 80 6)
    DATA_NOT_SAVED=$(write_with_file_ref "What must NOT be saved/logged (PII/security)" 80 6)
    EXTERNAL_SYSTEMS=$(write_with_file_ref "External systems/APIs/SDKs involved" 80 6)
    
    section_title "Edge Cases & Failure Recovery"
    OFFLINE_BEHAVIOR=$(write_with_file_ref "Offline/timeout behavior" 80 6)
    RETRY_RULES=$(write_with_file_ref "Retry rules" 80 6)
    APP_BACKGROUND=$(write_with_file_ref "What happens on app background/kill" 80 6)
    
    section_title "Acceptance Criteria"
    AC=$(write_with_file_ref "Acceptance criteria (Given/When/Then, one per line)" 80 12)
    
    section_title "Success Metrics (optional)"
    SUCCESS_METRIC=$(prompt_with_file_ref "Metric: " "e.g., login success rate")
    METRIC_BASELINE=$(prompt_with_file_ref "Baseline: " "e.g., N/A")
    METRIC_TARGET=$(prompt_with_file_ref "Target: " "e.g., 95%")
    METRIC_HOW=$(prompt_with_file_ref "How measured: " "e.g., analytics event")
    
    section_title "Open Questions"
    OPEN_Q=$(write_with_file_ref "Open questions (one per line)" 80 8)
    ;;
    
  "2")
    # Form 2: Change Request
    section_title "Change Summary"
    CHANGE_SUMMARY=$(write_with_file_ref "What is changing (1-2 lines)" 80 6)
    WHY_NOW=$(write_with_file_ref "Why now" 80 6)
    USER_IMPACT=$(write_with_file_ref "User impact" 80 6)
    BUSINESS_IMPACT=$(write_with_file_ref "Business impact" 80 6)
    
    section_title "Current vs Desired Behavior"
    CURRENT_BEHAVIOR=$(write_with_file_ref "Current behavior" 80 8)
    DESIRED_BEHAVIOR=$(write_with_file_ref "Desired behavior" 80 8)
    UNCHANGED=$(write_with_file_ref "What must remain unchanged (guardrails)" 80 6)
    COMPAT_CONCERNS=$(write_with_file_ref "Backward compatibility concerns (data/UI/API)" 80 6)
    
    section_title "UX / Behavior Changes"
    SCREENS=$(write_with_file_ref "Screens touched" 80 6)
    ENTRY_EXIT_CHANGES=$(write_with_file_ref "Entry/exit changes" 80 6)
    FIELD_CHANGES=$(write_with_file_ref "New/changed fields + validation messages" 80 8)
    ACTION_CHANGES=$(write_with_file_ref "New/changed actions + enablement rules" 80 8)
    STATE_CHANGES=$(write_with_file_ref "Loading/success/error/empty state changes" 80 8)
    
    section_title "Business Rules Changes"
    RULES_CHANGES=$(write_with_file_ref "Rules to add/change/remove" 80 8)
    BEFORE_AFTER=$(write_with_file_ref "Examples before → after" 80 8)
    
    section_title "Data Impact"
    DATA_ADDED=$(write_with_file_ref "Data added/modified/removed" 80 6)
    MIGRATION_REQ=$(prompt_with_file_ref "Migration required? " "yes/no/unknown")
    REPORTING_IMPACT=$(write_with_file_ref "Reporting/analytics impact" 80 6)
    
    section_title "Edge Cases"
    PRESERVED_SCENARIOS=$(write_with_file_ref "Scenarios that previously worked and must still work" 80 8)
    NEW_FAILURES=$(write_with_file_ref "New failure scenarios and recovery" 80 8)
    
    section_title "Acceptance Criteria"
    AC=$(write_with_file_ref "AC (covers old behavior preserved + new behavior + edge cases)" 80 12)
    
    section_title "Rollout Notes"
    FEATURE_FLAG=$(gum choose "yes" "no")
    INCREMENTAL=$(gum choose "yes" "no")
    ;;
    
  "3")
    # Form 3: Bug & Correctness
    section_title "Bug Details"
    SEVERITY=$(gum choose "Critical" "High" "Medium" "Low")
    FREQUENCY=$(gum choose "Always" "Often" "Sometimes" "Rare")
    FIRST_SEEN=$(prompt_with_file_ref "First seen (date/version): " "e.g., 2026-01-15 / v2.3.0")
    AFFECTED=$(write_with_file_ref "Affected versions/devices" 80 6)
    
    section_title "Bug Description"
    BUG_WHAT=$(write_with_file_ref "What is broken (1-2 lines)" 80 6)
    EXPECTED=$(write_with_file_ref "Expected behavior" 80 6)
    ACTUAL=$(write_with_file_ref "Actual behavior" 80 6)
    
    section_title "Reproduction Steps"
    REPRO=$(write_with_file_ref "Reproduction steps (numbered list)" 80 10)
    
    section_title "Environment"
    APP_VERSION=$(prompt_with_file_ref "App version/build: " "e.g., 2.3.0 (1234)")
    DEVICE_MODEL=$(prompt_with_file_ref "Device model(s): " "e.g., Pixel 6, Samsung S21")
    ANDROID_VERSION=$(prompt_with_file_ref "Android version(s): " "e.g., Android 13, 14")
    NETWORK=$(prompt_with_file_ref "Network condition: " "wifi/4G/offline")
    ACCOUNT_TYPE=$(prompt_with_file_ref "Account type/role: " "e.g., free user")
    
    section_title "Evidence"
    SCREENSHOTS=$(write_with_file_ref "Screenshots/video (links or paths)" 80 6)
    LOGS=$(write_with_file_ref "Logs (Crashlytics link, logcat snippet)" 80 6)
    SAMPLE_DATA=$(write_with_file_ref "Sample account/data to reproduce (if safe)" 80 6)
    
    section_title "Impact Assessment"
    USER_IMPACT=$(write_with_file_ref "User impact" 80 6)
    BUSINESS_IMPACT=$(write_with_file_ref "Business impact" 80 6)
    WORKAROUND=$(write_with_file_ref "Workaround available? (yes/no + steps)" 80 6)
    
    section_title "Suspected Cause (optional)"
    HYPOTHESIS=$(write_with_file_ref "Hypothesis" 80 6)
    RECENT_CHANGES=$(write_with_file_ref "Recent changes possibly related" 80 6)
    
    section_title "Acceptance Criteria (Fix Verification)"
    AC=$(write_with_file_ref "AC (Given/When/Then format)" 80 10)
    ;;
    
  "4")
    # Form 4: Feasibility / Design Consultation
    section_title "Business Question"
    DECISION_NEEDED=$(write_with_file_ref "What decision is needed" 80 6)
    WHY_MATTERS=$(write_with_file_ref "Why it matters" 80 6)
    IF_DELAY=$(write_with_file_ref "What happens if we delay" 80 6)
    
    section_title "Proposed Experience / Requirement"
    USER_SHOULD=$(write_with_file_ref "What user should be able to do" 80 8)
    CONSTRAINTS=$(write_with_file_ref "Constraints (policy, privacy, budget, time)" 80 8)
    
    section_title "Options Considered"
    OPTIONS=$(write_with_file_ref "Options A, B, C (one per paragraph)" 80 12)
    NEED_FROM_DEV=$(write_with_file_ref "What you need from senior dev (feasibility risks, recommended approach, rough effort, dependencies)" 80 10)
    
    section_title "Inputs to Support Decision"
    TARGET_USERS=$(write_with_file_ref "Target users" 80 6)
    PLATFORM_CONSTRAINTS=$(write_with_file_ref "Platforms/devices constraints" 80 6)
    NON_GOALS=$(write_with_file_ref "Non-goals" 80 6)
    INTEGRATION_CONSTRAINTS=$(write_with_file_ref "Integration constraints" 80 6)
    
    section_title "Output Expected from Senior Dev"
    OUTPUT_EXPECTED=$(write_with_file_ref "Recommended option + rationale, key risks/edge cases, spike needed?, follow-up tickets" 80 10)
    ;;
    
  "5")
    # Form 5: Integration & Dependencies
    section_title "Integration Summary"
    SYSTEM_NAME=$(prompt_with_file_ref "System/SDK/API to integrate: " "e.g., Stripe API")
    BUSINESS_GOAL=$(write_with_file_ref "Business goal" 80 6)
    USER_FACING=$(write_with_file_ref "User-facing change" 80 6)
    EXTERNAL_OWNER=$(prompt_with_file_ref "External owner/contact: " "e.g., vendor@example.com")
    
    section_title "Contract Requirements"
    DATA_REQUIRED=$(write_with_file_ref "Data required from integration (fields + meaning)" 80 8)
    DATA_SENT=$(write_with_file_ref "Data sent to integration (fields + meaning)" 80 8)
    SUCCESS_CRITERIA=$(write_with_file_ref "Success criteria" 80 6)
    ERROR_BEHAVIORS=$(write_with_file_ref "Error behaviors (what user sees; retry rules)" 80 8)
    RATE_LIMITS=$(write_with_file_ref "Rate limits / quotas (if known)" 80 6)
    
    section_title "Environments & Access"
    SANDBOX=$(write_with_file_ref "Sandbox/staging availability" 80 6)
    CREDENTIALS=$(write_with_file_ref "Credentials process" 80 6)
    SECURITY=$(write_with_file_ref "IP allowlist / security steps" 80 6)
    
    section_title "Dependencies & Blockers"
    BACKEND_CHANGES=$(write_with_file_ref "Backend changes needed" 80 6)
    LEGAL_REVIEW=$(write_with_file_ref "Legal/compliance review needed" 80 6)
    VENDOR_APPROVALS=$(write_with_file_ref "Vendor approvals needed" 80 6)
    
    section_title "Rollout & Compatibility"
    BACKWARD_COMPAT=$(write_with_file_ref "Backward compatibility" 80 6)
    FEATURE_FLAG=$(gum choose "yes" "no")
    FALLBACK=$(write_with_file_ref "Fallback if integration down" 80 6)
    
    section_title "Acceptance Criteria"
    AC=$(write_with_file_ref "AC (Given/When/Then format)" 80 10)
    ;;
    
  "6")
    # Form 6: Data & Analytics Request
    section_title "Business Question"
    DECISION=$(write_with_file_ref "What decision/report will this enable" 80 6)
    WHO_USES=$(write_with_file_ref "Who uses it" 80 6)
    FREQUENCY=$(prompt_with_file_ref "Frequency: " "daily/weekly/ad-hoc")
    
    section_title "Events / Tracking Requirements"
    EVENTS=$(write_with_file_ref "For each event: name, trigger (exact moment), properties (key → meaning), user identifiers allowed, expected volume" 80 15)
    
    section_title "Success Metrics"
    KPI_DEFS=$(write_with_file_ref "KPI definitions" 80 8)
    CALC_RULES=$(write_with_file_ref "Calculation rules" 80 6)
    SOURCE_TRUTH=$(write_with_file_ref "Source of truth (app vs backend)" 80 6)
    
    section_title "Validation Plan"
    VERIFY=$(write_with_file_ref "How to verify events fire correctly" 80 6)
    TEST_SCENARIOS=$(write_with_file_ref "Sample scenarios to test" 80 8)
    
    section_title "Acceptance Criteria"
    AC=$(write_with_file_ref "AC (Given/When/Then format)" 80 10)
    ;;
    
  "7")
    # Form 7: Quality / Performance / Reliability
    section_title "Problem Statement (with Evidence)"
    WHAT_SLOW=$(write_with_file_ref "What is slow/unstable" 80 6)
    EVIDENCE=$(write_with_file_ref "Evidence (metrics, screenshots, videos, ANR/crash rate)" 80 8)
    WHERE=$(write_with_file_ref "Where it happens (screen/flow)" 80 6)
    
    section_title "Target Improvement"
    METRIC_NAME=$(prompt_with_file_ref "Metric name: " "startup time / jank / memory / crash-free")
    BASELINE=$(prompt_with_file_ref "Baseline: " "e.g., 3.5s")
    TARGET=$(prompt_with_file_ref "Target: " "e.g., < 2s")
    MEASUREMENT=$(prompt_with_file_ref "Measurement method: " "tool/source")
    
    section_title "Scope"
    AFFECTED=$(write_with_file_ref "Affected flows/screens" 80 6)
    MUST_NOT_BREAK=$(write_with_file_ref "Must-not-break areas" 80 6)
    NON_GOALS=$(write_with_file_ref "Non-goals" 80 6)
    
    section_title "User Experience Requirements"
    USER_FEEL=$(write_with_file_ref "What user should feel/see after improvement" 80 6)
    LOADING_RETRY=$(write_with_file_ref "Loading/retry behavior expectations" 80 6)
    
    section_title "Acceptance Criteria"
    AC=$(write_with_file_ref "AC (baseline → target met, no regression, monitoring added)" 80 10)
    ;;
    
  "8")
    # Form 8: Security / Privacy / Compliance
    section_title "Driver"
    POLICY_REF=$(write_with_file_ref "Policy/regulation reference (if any)" 80 6)
    RISK_DESC=$(write_with_file_ref "Risk description (what could go wrong)" 80 6)
    DEADLINE=$(prompt_with_file_ref "Deadline (legal/compliance): " "e.g., 2026-03-01")
    
    section_title "Data Classification"
    DATA_INVOLVED=$(write_with_file_ref "Data involved" 80 6)
    IS_PII=$(gum choose "yes" "no")
    WHERE_APPEARS=$(write_with_file_ref "Where it appears (UI/logs/storage/network)" 80 6)
    
    section_title "Required Controls"
    CONSENT=$(write_with_file_ref "Consent requirements" 80 6)
    MASKING=$(write_with_file_ref "Masking/redaction rules" 80 6)
    RETENTION=$(write_with_file_ref "Retention/deletion rules" 80 6)
    ACCESS_CONTROL=$(write_with_file_ref "Access control rules" 80 6)
    ENCRYPTION=$(write_with_file_ref "Encryption requirements (at rest/in transit) if mandated" 80 6)
    
    section_title "UX Requirements"
    USER_COPY=$(write_with_file_ref "User-facing copy (exact text)" 80 8)
    SETTINGS=$(write_with_file_ref "Settings/toggles needed" 80 6)
    DENY_HANDLING=$(write_with_file_ref "Error handling if user denies consent" 80 6)
    
    section_title "Audit Requirements"
    RECORDED=$(write_with_file_ref "What must be recorded (who/what/when)" 80 6)
    EXPORT=$(write_with_file_ref "Export/report needs" 80 6)
    
    section_title "Acceptance Criteria"
    AC=$(write_with_file_ref "AC (Given/When/Then format)" 80 10)
    ;;
    
  "9")
    # Form 9: Release / Operations
    section_title "Request Type"
    REQUEST_TYPE=$(gum choose "Hotfix" "Phased rollout" "Enable feature flag" "Rollback support" "Monitoring change")
    
    section_title "Context"
    WHAT_RELEASING=$(write_with_file_ref "What is being released/changed" 80 6)
    WHY_NOW=$(write_with_file_ref "Why now" 80 6)
    RISK_LEVEL=$(gum choose "High" "Medium" "Low")
    
    section_title "Rollout Plan"
    ROLLOUT_STRATEGY=$(write_with_file_ref "Rollout strategy (phased/100%)" 80 6)
    TARGET_AUDIENCE=$(write_with_file_ref "Target audience" 80 6)
    KILL_SWITCH=$(gum choose "yes" "no")
    FALLBACK=$(write_with_file_ref "Fallback behavior if issues occur" 80 6)
    
    section_title "Monitoring & Support"
    METRICS=$(write_with_file_ref "Metrics to monitor" 80 6)
    ALERTS=$(write_with_file_ref "Alert thresholds (if any)" 80 6)
    SUPPORT_INSTRUCTIONS=$(write_with_file_ref "Support instructions (what to tell users)" 80 8)
    KNOWN_ISSUES=$(write_with_file_ref "Known issues + workaround" 80 6)
    
    section_title "Acceptance Criteria"
    AC=$(write_with_file_ref "AC (Given/When/Then format)" 80 10)
    ;;
    
  "10")
    # Form 10: Tech Debt / Maintainability
    section_title "Why This Matters"
    WHAT_HARD=$(write_with_file_ref "What changes are hard today" 80 6)
    COST_NOT_FIXING=$(write_with_file_ref "Cost of not fixing (time, bugs, missed deadlines)" 80 8)
    BLOCKED=$(write_with_file_ref "What feature work is blocked/slow because of this" 80 6)
    
    section_title "Desired Outcome"
    SHOULD_BECOME=$(write_with_file_ref "What should become easier/faster" 80 6)
    QUALITY_IMPROVE=$(write_with_file_ref "What quality should improve (testability, modularity)" 80 6)
    NON_GOALS=$(write_with_file_ref "Non-goals (no big rewrites beyond scope)" 80 6)
    
    section_title "Scope Boundaries"
    AREAS_REFACTOR=$(write_with_file_ref "Areas to refactor" 80 6)
    AREAS_NOT_TOUCH=$(write_with_file_ref "Areas not to touch" 80 6)
    RISK_AREAS=$(write_with_file_ref "Risk areas" 80 6)
    
    section_title "Acceptance Criteria"
    AC=$(write_with_file_ref "AC (future change X becomes possible within Y effort, regression risk reduced, docs updated)" 80 10)
    ;;
    
  "11")
    # Form 11: AI-era Workflow / Guardrails
    section_title "Problem Statement"
    AI_WRONG=$(write_with_file_ref "What AI/codegen is doing wrong" 80 8)
    EXAMPLES=$(write_with_file_ref "Examples (paste snippets or links)" 80 10)
    IMPACT=$(write_with_file_ref "Impact (bugs, rework, slow reviews)" 80 6)
    
    section_title "Desired Guardrails"
    MUST_ENFORCE=$(write_with_file_ref "What must be enforced (rules)" 80 8)
    FORBIDDEN=$(write_with_file_ref "Forbidden patterns" 80 8)
    REQUIRED=$(write_with_file_ref "Required patterns" 80 8)
    DOD_CHECKS=$(write_with_file_ref "Definition of Done checks (what CI should fail on)" 80 8)
    
    section_title "Inputs & Outputs"
    INPUTS=$(write_with_file_ref "Inputs (spec format, templates, prompts)" 80 8)
    OUTPUTS=$(write_with_file_ref "Output artifacts expected (tests, docs, file structure)" 80 8)
    INTEGRATION=$(write_with_file_ref "Where it should be integrated (pre-commit/CI/PR checks)" 80 6)
    
    section_title "Acceptance Criteria"
    AC=$(write_with_file_ref "AC (CI fails with clear message on violation, passes on compliance, reduces review time/defect rate)" 80 10)
    
    section_title "Example Good vs Bad"
    GOOD_EXAMPLE=$(write_with_file_ref "Good example" 80 8)
    BAD_EXAMPLE=$(write_with_file_ref "Bad example" 80 8)
    ;;
esac

# -----------------------------
# Write Markdown
# -----------------------------
OUT_DIR="specs"
mkdir -p "$OUT_DIR"
OUT_PATH="${OUT_DIR}/${DATE_PREFIX}-${SLUG}.md"

# Generate markdown based on template
case "$TEMPLATE_NUM" in
  "1")
    cat > "$OUT_PATH" <<EOF
# Ticket: ${TITLE}

- Date: ${DATE_YMD}
- Template: New Feature Delivery
- Priority: $(val_or_tbd "$PRIORITY")
- Target Release: $(val_or_tbd "$TARGET_RELEASE")
- Owner (BA): $(val_or_tbd "$OWNER_BA")

---

## Stakeholders
$(bullets "$STAKEHOLDERS")

---

## Problem & Goal

### Problem statement (current pain)
$(val_or_tbd "$PROBLEM_STATEMENT")

### Goal (what users can do after)
$(val_or_tbd "$GOAL")

### Business value
$(val_or_tbd "$BUSINESS_VALUE")

### Non-goals (explicitly out of scope)
$(bullets "$NON_GOALS")

---

## Users & Permissions

### Primary users
$(bullets "$PRIMARY_USERS")

### Secondary users
$(bullets "$SECONDARY_USERS")

### Permission rules
$(val_or_tbd "$PERMISSION_RULES")

### Preconditions
$(val_or_tbd "$PRECONDITIONS")

---

## UX / Behavior (not pixel-perfect)

### Screens involved
$(bullets "$SCREENS")

### Entry points
$(bullets "$ENTRY_POINTS")

### Exit points
- On success: $(val_or_tbd "$EXIT_SUCCESS")
- On cancel/back: $(val_or_tbd "$EXIT_CANCEL")

### Draft/partial progress rule
$(val_or_tbd "$DRAFT_RULE")

### Inputs (fields + constraints + exact validation messages)
$(val_or_tbd "$INPUTS")

### Actions (CTA enabled rules + double-submit prevention)
$(val_or_tbd "$ACTIONS")

### Feedback (loading, success, error style, empty state)
$(val_or_tbd "$FEEDBACK")

### Accessibility/localization expectations
$(val_or_tbd "$ACCESSIBILITY")

---

## Business Rules

### Validation rules (with examples)
$(bullets "$VALIDATION_RULES")

### Decision rules (if/then + examples)
$(bullets "$DECISION_RULES")

### Ordering/dedup/idempotency rules
$(bullets "$ORDERING_RULES")

---

## Data & Integrations (business view)

### Data inputs used
$(bullets "$DATA_INPUTS")

### Data outputs shown
$(bullets "$DATA_OUTPUTS")

### What must be saved + when
$(bullets "$DATA_SAVED")

### What must NOT be saved/logged (PII/security)
$(bullets "$DATA_NOT_SAVED")

### External systems/APIs/SDKs involved
$(bullets "$EXTERNAL_SYSTEMS")

---

## Edge Cases & Failure Recovery

### Offline/timeout behavior
$(val_or_tbd "$OFFLINE_BEHAVIOR")

### Retry rules
$(val_or_tbd "$RETRY_RULES")

### What happens on app background/kill
$(val_or_tbd "$APP_BACKGROUND")

---

## Acceptance Criteria (Given/When/Then)
$(bullets "$AC")

---

## Success Metrics

- Metric: $(val_or_tbd "$SUCCESS_METRIC")
- Baseline: $(val_or_tbd "$METRIC_BASELINE")
- Target: $(val_or_tbd "$METRIC_TARGET")
- How measured: $(val_or_tbd "$METRIC_HOW")

---

## Open Questions
$(bullets "$OPEN_Q")
EOF
    ;;
    
  "2")
    cat > "$OUT_PATH" <<EOF
# Ticket: ${TITLE}

- Date: ${DATE_YMD}
- Template: Change Request to Existing Feature
- Priority: $(val_or_tbd "$PRIORITY")
- Target Release: $(val_or_tbd "$TARGET_RELEASE")
- Owner (BA): $(val_or_tbd "$OWNER_BA")

---

## Stakeholders
$(bullets "$STAKEHOLDERS")

---

## Change Summary

### What is changing
$(val_or_tbd "$CHANGE_SUMMARY")

### Why now
$(val_or_tbd "$WHY_NOW")

### User impact
$(val_or_tbd "$USER_IMPACT")

### Business impact
$(val_or_tbd "$BUSINESS_IMPACT")

---

## Current vs Desired Behavior

### Current behavior
$(val_or_tbd "$CURRENT_BEHAVIOR")

### Desired behavior
$(val_or_tbd "$DESIRED_BEHAVIOR")

### What must remain unchanged (guardrails)
$(val_or_tbd "$UNCHANGED")

### Backward compatibility concerns
$(val_or_tbd "$COMPAT_CONCERNS")

---

## UX / Behavior Changes

### Screens touched
$(bullets "$SCREENS")

### Entry/exit changes
$(val_or_tbd "$ENTRY_EXIT_CHANGES")

### New/changed fields + validation messages
$(val_or_tbd "$FIELD_CHANGES")

### New/changed actions + enablement rules
$(val_or_tbd "$ACTION_CHANGES")

### Loading/success/error/empty state changes
$(val_or_tbd "$STATE_CHANGES")

---

## Business Rules Changes

### Rules to add/change/remove
$(bullets "$RULES_CHANGES")

### Examples before → after
$(val_or_tbd "$BEFORE_AFTER")

---

## Data Impact

### Data added/modified/removed
$(bullets "$DATA_ADDED")

### Migration required?
$(val_or_tbd "$MIGRATION_REQ")

### Reporting/analytics impact
$(val_or_tbd "$REPORTING_IMPACT")

---

## Edge Cases

### Scenarios that previously worked and must still work
$(bullets "$PRESERVED_SCENARIOS")

### New failure scenarios and recovery
$(bullets "$NEW_FAILURES")

---

## Acceptance Criteria
$(bullets "$AC")

---

## Rollout Notes

- Feature flag needed? $(val_or_tbd "$FEATURE_FLAG")
- Incremental rollout? $(val_or_tbd "$INCREMENTAL")
EOF
    ;;
    
  "3")
    cat > "$OUT_PATH" <<EOF
# Ticket: ${TITLE}

- Date: ${DATE_YMD}
- Template: Bug & Correctness
- Severity: $(val_or_tbd "$SEVERITY")
- Frequency: $(val_or_tbd "$FREQUENCY")
- First seen: $(val_or_tbd "$FIRST_SEEN")
- Owner (BA): $(val_or_tbd "$OWNER_BA")

---

## Stakeholders
$(bullets "$STAKEHOLDERS")

---

## Affected Versions/Devices
$(val_or_tbd "$AFFECTED")

---

## Bug Description

### What is broken
$(val_or_tbd "$BUG_WHAT")

### Expected behavior
$(val_or_tbd "$EXPECTED")

### Actual behavior
$(val_or_tbd "$ACTUAL")

---

## Reproduction Steps
$(bullets "$REPRO")

---

## Environment

- App version/build: $(val_or_tbd "$APP_VERSION")
- Device model(s): $(val_or_tbd "$DEVICE_MODEL")
- Android version(s): $(val_or_tbd "$ANDROID_VERSION")
- Network condition: $(val_or_tbd "$NETWORK")
- Account type/role: $(val_or_tbd "$ACCOUNT_TYPE")

---

## Evidence

### Screenshots/video
$(val_or_tbd "$SCREENSHOTS")

### Logs
$(val_or_tbd "$LOGS")

### Sample account/data
$(val_or_tbd "$SAMPLE_DATA")

---

## Impact Assessment

### User impact
$(val_or_tbd "$USER_IMPACT")

### Business impact
$(val_or_tbd "$BUSINESS_IMPACT")

### Workaround available?
$(val_or_tbd "$WORKAROUND")

---

## Suspected Cause

### Hypothesis
$(val_or_tbd "$HYPOTHESIS")

### Recent changes possibly related
$(val_or_tbd "$RECENT_CHANGES")

---

## Acceptance Criteria (Fix Verification)
$(bullets "$AC")
EOF
    ;;
    
  "4")
    cat > "$OUT_PATH" <<EOF
# Ticket: ${TITLE}

- Date: ${DATE_YMD}
- Template: Feasibility / Design Consultation
- Priority: $(val_or_tbd "$PRIORITY")
- Decision needed by: $(val_or_tbd "$TARGET_RELEASE")
- Owner (BA): $(val_or_tbd "$OWNER_BA")

---

## Stakeholders
$(bullets "$STAKEHOLDERS")

---

## Business Question

### What decision is needed
$(val_or_tbd "$DECISION_NEEDED")

### Why it matters
$(val_or_tbd "$WHY_MATTERS")

### What happens if we delay
$(val_or_tbd "$IF_DELAY")

---

## Proposed Experience / Requirement

### What user should be able to do
$(val_or_tbd "$USER_SHOULD")

### Constraints
$(val_or_tbd "$CONSTRAINTS")

---

## Options Considered (BA view)
$(val_or_tbd "$OPTIONS")

### What you need from senior dev
$(val_or_tbd "$NEED_FROM_DEV")

---

## Inputs to Support Decision

### Target users
$(bullets "$TARGET_USERS")

### Platforms/devices constraints
$(val_or_tbd "$PLATFORM_CONSTRAINTS")

### Non-goals
$(bullets "$NON_GOALS")

### Integration constraints
$(val_or_tbd "$INTEGRATION_CONSTRAINTS")

---

## Output Expected from Senior Dev
$(val_or_tbd "$OUTPUT_EXPECTED")
EOF
    ;;
    
  "5")
    cat > "$OUT_PATH" <<EOF
# Ticket: ${TITLE}

- Date: ${DATE_YMD}
- Template: Integration & Dependencies
- Priority: $(val_or_tbd "$PRIORITY")
- Target Release: $(val_or_tbd "$TARGET_RELEASE")
- Owner (BA): $(val_or_tbd "$OWNER_BA")
- External Owner: $(val_or_tbd "$EXTERNAL_OWNER")

---

## Stakeholders
$(bullets "$STAKEHOLDERS")

---

## Integration Summary

### System/SDK/API to integrate
$(val_or_tbd "$SYSTEM_NAME")

### Business goal
$(val_or_tbd "$BUSINESS_GOAL")

### User-facing change
$(val_or_tbd "$USER_FACING")

---

## Contract Requirements (business-level)

### Data required from integration
$(val_or_tbd "$DATA_REQUIRED")

### Data sent to integration
$(val_or_tbd "$DATA_SENT")

### Success criteria
$(val_or_tbd "$SUCCESS_CRITERIA")

### Error behaviors
$(val_or_tbd "$ERROR_BEHAVIORS")

### Rate limits / quotas
$(val_or_tbd "$RATE_LIMITS")

---

## Environments & Access

### Sandbox/staging availability
$(val_or_tbd "$SANDBOX")

### Credentials process
$(val_or_tbd "$CREDENTIALS")

### IP allowlist / security steps
$(val_or_tbd "$SECURITY")

---

## Dependencies & Blockers

### Backend changes needed
$(val_or_tbd "$BACKEND_CHANGES")

### Legal/compliance review needed
$(val_or_tbd "$LEGAL_REVIEW")

### Vendor approvals needed
$(val_or_tbd "$VENDOR_APPROVALS")

---

## Rollout & Compatibility

### Backward compatibility
$(val_or_tbd "$BACKWARD_COMPAT")

### Feature flag required?
$(val_or_tbd "$FEATURE_FLAG")

### Fallback if integration down
$(val_or_tbd "$FALLBACK")

---

## Acceptance Criteria
$(bullets "$AC")
EOF
    ;;
    
  "6")
    cat > "$OUT_PATH" <<EOF
# Ticket: ${TITLE}

- Date: ${DATE_YMD}
- Template: Data & Analytics Request
- Priority: $(val_or_tbd "$PRIORITY")
- Target Date: $(val_or_tbd "$TARGET_RELEASE")
- Owner (BA): $(val_or_tbd "$OWNER_BA")

---

## Stakeholders
$(bullets "$STAKEHOLDERS")

---

## Business Question

### What decision/report will this enable
$(val_or_tbd "$DECISION")

### Who uses it
$(val_or_tbd "$WHO_USES")

### Frequency
$(val_or_tbd "$FREQUENCY")

---

## Events / Tracking Requirements
$(val_or_tbd "$EVENTS")

---

## Success Metrics

### KPI definitions
$(val_or_tbd "$KPI_DEFS")

### Calculation rules
$(val_or_tbd "$CALC_RULES")

### Source of truth
$(val_or_tbd "$SOURCE_TRUTH")

---

## Validation Plan

### How to verify events fire correctly
$(val_or_tbd "$VERIFY")

### Sample scenarios to test
$(bullets "$TEST_SCENARIOS")

---

## Acceptance Criteria
$(bullets "$AC")
EOF
    ;;
    
  "7")
    cat > "$OUT_PATH" <<EOF
# Ticket: ${TITLE}

- Date: ${DATE_YMD}
- Template: Quality / Performance / Reliability
- Priority: $(val_or_tbd "$PRIORITY")
- Target Release: $(val_or_tbd "$TARGET_RELEASE")
- Owner (BA): $(val_or_tbd "$OWNER_BA")

---

## Stakeholders
$(bullets "$STAKEHOLDERS")

---

## Problem Statement (with Evidence)

### What is slow/unstable
$(val_or_tbd "$WHAT_SLOW")

### Evidence
$(val_or_tbd "$EVIDENCE")

### Where it happens
$(val_or_tbd "$WHERE")

---

## Target Improvement

- Metric name: $(val_or_tbd "$METRIC_NAME")
- Baseline: $(val_or_tbd "$BASELINE")
- Target: $(val_or_tbd "$TARGET")
- Measurement method: $(val_or_tbd "$MEASUREMENT")

---

## Scope

### Affected flows/screens
$(bullets "$AFFECTED")

### Must-not-break areas
$(bullets "$MUST_NOT_BREAK")

### Non-goals
$(bullets "$NON_GOALS")

---

## User Experience Requirements

### What user should feel/see after improvement
$(val_or_tbd "$USER_FEEL")

### Loading/retry behavior expectations
$(val_or_tbd "$LOADING_RETRY")

---

## Acceptance Criteria
$(bullets "$AC")
EOF
    ;;
    
  "8")
    cat > "$OUT_PATH" <<EOF
# Ticket: ${TITLE}

- Date: ${DATE_YMD}
- Template: Security / Privacy / Compliance
- Priority: $(val_or_tbd "$PRIORITY")
- Deadline: $(val_or_tbd "$DEADLINE")
- Owner (BA): $(val_or_tbd "$OWNER_BA")

---

## Stakeholders
$(bullets "$STAKEHOLDERS")

---

## Driver

### Policy/regulation reference
$(val_or_tbd "$POLICY_REF")

### Risk description
$(val_or_tbd "$RISK_DESC")

---

## Data Classification

### Data involved
$(val_or_tbd "$DATA_INVOLVED")

### Is it PII/sensitive?
$(val_or_tbd "$IS_PII")

### Where it appears
$(val_or_tbd "$WHERE_APPEARS")

---

## Required Controls (business requirements)

### Consent requirements
$(val_or_tbd "$CONSENT")

### Masking/redaction rules
$(val_or_tbd "$MASKING")

### Retention/deletion rules
$(val_or_tbd "$RETENTION")

### Access control rules
$(val_or_tbd "$ACCESS_CONTROL")

### Encryption requirements
$(val_or_tbd "$ENCRYPTION")

---

## UX Requirements

### User-facing copy (exact text)
$(val_or_tbd "$USER_COPY")

### Settings/toggles needed
$(val_or_tbd "$SETTINGS")

### Error handling if user denies consent
$(val_or_tbd "$DENY_HANDLING")

---

## Audit Requirements

### What must be recorded
$(val_or_tbd "$RECORDED")

### Export/report needs
$(val_or_tbd "$EXPORT")

---

## Acceptance Criteria
$(bullets "$AC")
EOF
    ;;
    
  "9")
    cat > "$OUT_PATH" <<EOF
# Ticket: ${TITLE}

- Date: ${DATE_YMD}
- Template: Release / Operations
- Priority: $(val_or_tbd "$PRIORITY")
- Release window: $(val_or_tbd "$TARGET_RELEASE")
- Owner (BA): $(val_or_tbd "$OWNER_BA")

---

## Stakeholders
$(bullets "$STAKEHOLDERS")

---

## Request Type
$(val_or_tbd "$REQUEST_TYPE")

---

## Context

### What is being released/changed
$(val_or_tbd "$WHAT_RELEASING")

### Why now
$(val_or_tbd "$WHY_NOW")

### Risk level
$(val_or_tbd "$RISK_LEVEL")

---

## Rollout Plan (business-level)

### Rollout strategy
$(val_or_tbd "$ROLLOUT_STRATEGY")

### Target audience
$(val_or_tbd "$TARGET_AUDIENCE")

### Kill switch required?
$(val_or_tbd "$KILL_SWITCH")

### Fallback behavior if issues occur
$(val_or_tbd "$FALLBACK")

---

## Monitoring & Support

### Metrics to monitor
$(bullets "$METRICS")

### Alert thresholds
$(val_or_tbd "$ALERTS")

### Support instructions
$(val_or_tbd "$SUPPORT_INSTRUCTIONS")

### Known issues + workaround
$(val_or_tbd "$KNOWN_ISSUES")

---

## Acceptance Criteria
$(bullets "$AC")
EOF
    ;;
    
  "10")
    cat > "$OUT_PATH" <<EOF
# Ticket: ${TITLE}

- Date: ${DATE_YMD}
- Template: Tech Debt / Maintainability
- Priority: $(val_or_tbd "$PRIORITY")
- Target window: $(val_or_tbd "$TARGET_RELEASE")
- Owner (BA): $(val_or_tbd "$OWNER_BA")

---

## Stakeholders
$(bullets "$STAKEHOLDERS")

---

## Why This Matters (from BA/product perspective)

### What changes are hard today
$(val_or_tbd "$WHAT_HARD")

### Cost of not fixing
$(val_or_tbd "$COST_NOT_FIXING")

### What feature work is blocked/slow
$(val_or_tbd "$BLOCKED")

---

## Desired Outcome (not implementation)

### What should become easier/faster
$(val_or_tbd "$SHOULD_BECOME")

### What quality should improve
$(val_or_tbd "$QUALITY_IMPROVE")

### Non-goals
$(bullets "$NON_GOALS")

---

## Scope Boundaries

### Areas to refactor
$(bullets "$AREAS_REFACTOR")

### Areas not to touch
$(bullets "$AREAS_NOT_TOUCH")

### Risk areas
$(bullets "$RISK_AREAS")

---

## Acceptance Criteria (business-level)
$(bullets "$AC")
EOF
    ;;
    
  "11")
    cat > "$OUT_PATH" <<EOF
# Ticket: ${TITLE}

- Date: ${DATE_YMD}
- Template: AI-era Workflow / Guardrails
- Priority: $(val_or_tbd "$PRIORITY")
- Target date: $(val_or_tbd "$TARGET_RELEASE")
- Owner (BA): $(val_or_tbd "$OWNER_BA")

---

## Stakeholders
$(bullets "$STAKEHOLDERS")

---

## Problem Statement

### What AI/codegen is doing wrong
$(val_or_tbd "$AI_WRONG")

### Examples
$(val_or_tbd "$EXAMPLES")

### Impact
$(val_or_tbd "$IMPACT")

---

## Desired Guardrails

### What must be enforced (rules)
$(bullets "$MUST_ENFORCE")

### Forbidden patterns
$(bullets "$FORBIDDEN")

### Required patterns
$(bullets "$REQUIRED")

### Definition of Done checks
$(bullets "$DOD_CHECKS")

---

## Inputs & Outputs

### Inputs
$(val_or_tbd "$INPUTS")

### Output artifacts expected
$(val_or_tbd "$OUTPUTS")

### Where it should be integrated
$(val_or_tbd "$INTEGRATION")

---

## Acceptance Criteria
$(bullets "$AC")

---

## Example "good vs bad"

### Good example
\`\`\`
$(val_or_tbd "$GOOD_EXAMPLE")
\`\`\`

### Bad example
\`\`\`
$(val_or_tbd "$BAD_EXAMPLE")
\`\`\`
EOF
    ;;
esac

gum style --bold "✅ Generated: $OUT_PATH"
echo ""
gum style --italic "💡 Remember: You can reference files/folders using # in any field"

if gum confirm "Open now in nano?"; then
  nano "$OUT_PATH"
fi
