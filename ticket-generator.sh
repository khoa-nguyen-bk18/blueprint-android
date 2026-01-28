#!/bin/bash

# Configuration
SPECS_DIR="specs"
DATE_PREFIX=$(date +%Y%m%d)

# Ensure dependencies exist
if ! command -v gum &> /dev/null; then
    echo "Error: 'gum' is not installed."
    exit 1
fi
if ! command -v fzf &> /dev/null; then
    echo "Error: 'fzf' is not installed."
    exit 1
fi

mkdir -p "$SPECS_DIR"

# --- HELPER: SMART FILE LISTING ---
# This function respects .gitignore if present, otherwise filters common junk
get_file_list() {
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        # 1. Best method: Use git to respect .gitignore
        # --cached: files in index
        # --others: new files not added yet
        # --exclude-standard: apply .gitignore rules
        git ls-files --cached --others --exclude-standard
    else
        # 2. Fallback: Standard find (recursive)
        # Excludes: .git, node_modules, .DS_Store
        find . -type f \
            -not -path '*/.*' \
            -not -path '*/node_modules/*' \
            -not -path '*/dist/*' \
            -not -path '*/build/*' \
            -not -name '.DS_Store'
    fi
}

# --- INPUT HANDLERS ---

# Function to handle single-line input with '#' file trigger
ask_input() {
    local prompt="$1"
    local placeholder="$2"
    local value=""
    
    while true; do
        # 1. Output prompt to STDERR
        gum style --foreground 212 -- "$prompt" >&2
        
        # 2. Capture user input
        input=$(gum input --placeholder "$placeholder" --value "$value" --width 80)
        
        # 3. Check for Trigger (# at the end)
        if [[ "$input" =~ \#$ ]]; then
            base_input="${input%#}"
            
            # Select file using the smart list function
            selected_file=$(get_file_list | fzf --height=40% --layout=reverse --border --prompt="Select file > " --preview 'head -n 10 {}')
            
            if [[ -n "$selected_file" ]]; then
                filename=$(basename "$selected_file")
                value="${base_input}[${filename}](${selected_file}) "
            else
                value="$base_input"
            fi
        else
            if [[ -z "$input" ]]; then
                echo "N/A"
            else
                echo "$input"
            fi
            break
        fi
    done
}

# Function to handle multi-line input with '#' file trigger
ask_text() {
    local header="$1"
    local placeholder="$2"
    local value=""

    while true; do
        # 1. Output Headers to STDERR
        gum style --foreground 212 -- "$header" >&2
        echo -e "\033[2m(Type '#' at end and press Ctrl+D to insert file)\033[0m" >&2
        
        # 2. Capture input
        input=$(gum write --placeholder "$placeholder" --value "$value" --width 80 --height 10 --show-cursor-line --show-line-numbers)
        
        # 3. Check for Trigger (# at end)
        trimmed_input=$(echo "$input" | sed 's/[[:space:]]*$//')
        
        if [[ "$trimmed_input" =~ \#$ ]]; then
            base_input="${trimmed_input%#}"
            
            # Select file using smart list
            selected_file=$(get_file_list | fzf --height=40% --layout=reverse --border --prompt="Select file > " --preview 'head -n 10 {}')
            
            if [[ -n "$selected_file" ]]; then
                filename=$(basename "$selected_file")
                value="${base_input} [${filename}](${selected_file})"
            else
                value="$base_input"
            fi
        else
            if [[ -z "$input" ]]; then
                echo "N/A"
            else
                echo "$input"
            fi
            break
        fi
    done
}

slugify() {
    echo "$1" | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z
}

# --- TEMPLATE SELECTION ---

clear
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 -- "BA → Senior Dev Ticket Wizard"

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

TEMPLATE_ID=$(echo "$TEMPLATE" | cut -d')' -f1)
TEMPLATE_NAME=$(echo "$TEMPLATE" | cut -d')' -f2 | xargs)

# --- COMMON HEADER ---

gum style --foreground 99 -- "--- Ticket Header ---" >&2
TITLE=$(ask_input "Ticket Title:" "e.g. Implement Login Validation")
PRIORITY=$(gum choose "P0 (Critical)" "P1 (High)" "P2 (Medium)" "P3 (Low)" | cut -d' ' -f1)
TARGET=$(ask_input "Target Release/Date:" "YYYY-MM-DD or v1.2")
OWNER=$(ask_input "Owner (BA):" "Your Name")
STAKEHOLDERS=$(ask_input "Stakeholders:" "Names of interested parties")

CONTENT=""

# --- FIELD DEFINITIONS ---

collect_feature() {
    gum style --foreground 99 -- "--- Problem & Goal ---" >&2
    PROB=$(ask_text "Problem Statement" "Current pain point...")
    GOAL=$(ask_text "Goal" "What users can do after...")
    VALUE=$(ask_text "Business Value" "Why this matters...")
    NONGOAL=$(ask_text "Non-goals" "Explicitly out of scope...")

    gum style --foreground 99 -- "--- Users & Permissions ---" >&2
    USERS=$(ask_input "Primary Users:" "Who is this for?")
    PERMS=$(ask_input "Permission Rules:" "Admin only?")
    PRECON=$(ask_text "Preconditions" "Login state, setup required...")

    gum style --foreground 99 -- "--- UX / Behavior ---" >&2
    SCREENS=$(ask_input "Screens Involved:" "List screen names")
    ENTRY=$(ask_input "Entry Points:" "How user gets here")
    INPUTS=$(ask_text "Inputs & Validation" "Fields, constraints, exact messages...")
    ACTIONS=$(ask_text "Actions" "CTA behavior...")
    FEEDBACK=$(ask_input "Feedback:" "Loading states, success toasts")

    gum style --foreground 99 -- "--- Business Rules ---" >&2
    RULES=$(ask_text "Logic Rules" "Validation, decision trees...")
    
    gum style --foreground 99 -- "--- Data & Integrations ---" >&2
    DATA_SAVE=$(ask_text "Data Persistence" "What must be saved/logged...")
    APIS=$(ask_input "External APIs:" "Systems involved")

    gum style --foreground 99 -- "--- Acceptance Criteria ---" >&2
    ACS=$(ask_text "Acceptance Criteria (Gherkin)" "Given/When/Then list...")

    CONTENT="
## Problem & goal
- **Problem statement:** $PROB
- **Goal:** $GOAL
- **Business value:** $VALUE
- **Non-goals:** $NONGOAL

## Users & permissions
- **Primary users:** $USERS
- **Permission rules:** $PERMS
- **Preconditions:** $PRECON

## UX / behavior
- **Screens involved:** $SCREENS
- **Entry points:** $ENTRY
- **Inputs:** $INPUTS
- **Actions:** $ACTIONS
- **Feedback:** $FEEDBACK

## Business rules
- **Validation/Logic:** $RULES

## Data & integrations
- **Persistence:** $DATA_SAVE
- **External Systems:** $APIS

## Acceptance criteria
$ACS
"
}

collect_change_request() {
    gum style --foreground 99 -- "--- Change Details ---" >&2
    SUMMARY=$(ask_text "Change Summary" "What is changing and why...")
    CURRENT=$(ask_text "Current Behavior" "How it works now...")
    DESIRED=$(ask_text "Desired Behavior" "How it should work...")
    GUARDRAILS=$(ask_text "Guardrails" "What must remain unchanged...")
    COMPAT=$(ask_input "Backward Compatibility:" "Data/UI/API concerns")
    ACS=$(ask_text "Acceptance Criteria" "Verify old vs new behavior...")

    CONTENT="
## Change summary
- **What/Why:** $SUMMARY

## Current vs desired behavior
- **Current:** $CURRENT
- **Desired:** $DESIRED
- **Guardrails (Unchanged):** $GUARDRAILS
- **Backward Compatibility:** $COMPAT

## Acceptance criteria
$ACS
"
}

collect_bug() {
    gum style --foreground 99 -- "--- Bug Details ---" >&2
    SEVERITY=$(gum choose "Critical" "High" "Medium" "Low")
    FREQ=$(gum choose "Always" "Often" "Sometimes" "Rare")
    DESC=$(ask_text "Bug Description" "Expected vs Actual...")
    STEPS=$(ask_text "Reproduction Steps" "1. Go to... 2. Click...")
    ENV=$(ask_text "Environment" "Device, OS, Version...")
    EVIDENCE=$(ask_text "Evidence" "Links to screenshots/logs (# to link file)...")
    IMPACT=$(ask_text "Impact" "User/Business impact...")

    CONTENT="
## Bug Metadata
- **Severity:** $SEVERITY
- **Frequency:** $FREQ

## Bug description
$DESC

## Reproduction steps
$STEPS

## Environment
$ENV

## Evidence
$EVIDENCE

## Impact
$IMPACT
"
}

collect_generic() {
    gum style --foreground 99 -- "--- Requirements ---" >&2
    DESC=$(ask_text "Description / Requirements" "Enter the detailed requirements based on the template...")
    ACS=$(ask_text "Acceptance Criteria" "List ACs...")

    CONTENT="
## Requirements
$DESC

## Acceptance criteria
$ACS
"
}

# --- RUNNER ---

case $TEMPLATE_ID in
    1) collect_feature ;;
    2) collect_change_request ;;
    3) collect_bug ;;
    *) collect_generic ;; 
esac

# --- SAVE FILE ---

SLUG=$(slugify "$TITLE")
FILENAME="${SPECS_DIR}/${DATE_PREFIX}-${SLUG}.md"

cat > "$FILENAME" <<EOF
# [${TEMPLATE_ID}] ${TITLE}

> **Template:** ${TEMPLATE_NAME}
> **Date:** $(date +%Y-%m-%d)

## Ticket header
- **Title:** ${TITLE}
- **Priority:** ${PRIORITY}
- **Target:** ${TARGET}
- **Owner:** ${OWNER}
- **Stakeholders:** ${STAKEHOLDERS}

${CONTENT}

---
Generated by spec-wizard.tui.sh
EOF

gum style --border double --margin "1" --padding "1" --border-foreground 212 -- "Ticket saved to:" "$FILENAME" >&2