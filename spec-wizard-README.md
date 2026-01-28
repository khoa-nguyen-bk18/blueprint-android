# BA → Senior Dev Ticket Wizard

An interactive TUI wizard for creating structured tickets using 11 different templates.

## Requirements

Install `gum` (charmbracelet TUI framework):

```bash
# macOS
brew install gum

# Termux
pkg install gum
```

## Usage

```bash
./spec-wizard.tui.sh
```

## Features

### 11 Ticket Templates

1. **New Feature Delivery** - Complete feature spec with UX, business rules, data requirements
2. **Change Request to Existing Feature** - Track changes to existing functionality
3. **Bug & Correctness** - Structured bug reports with repro steps and environment
4. **Feasibility / Design Consultation** - Pre-implementation design exploration
5. **Integration & Dependencies** - External API/SDK integration specs
6. **Data & Analytics Request** - Event tracking and metrics requirements
7. **Quality / Performance / Reliability** - Performance improvement tickets
8. **Security / Privacy / Compliance** - Security and privacy requirements
9. **Release / Operations** - Rollout plans and operational changes
10. **Tech Debt / Maintainability** - Refactoring and code quality improvements
11. **AI-era Workflow / Guardrails** - AI codegen rules and quality gates

### File/Folder References

Type `#` in any input field to reference files/folders from your workspace:

- **In single-line inputs**: Type `#` and select a file/folder
- **In multi-line inputs**: Type `#` on a new line to insert file references

Selected files are automatically inserted as markdown links: `[filename](path/to/file)`

### Output

Generated tickets are saved to `specs/YYYYMMDD-slug.md` with:
- Date-prefixed filename for chronological ordering
- Slugified title for clean filenames
- Structured markdown sections matching the selected template
- N/A defaults for empty optional fields

### Example Workflow

1. Run the wizard: `./spec-wizard.tui.sh`
2. Select a template (e.g., "1) New Feature Delivery")
3. Fill in ticket header fields (title, priority, target release, owner, stakeholders)
4. Answer template-specific prompts
5. Use `#` to reference existing files/folders when needed
6. Review the generated markdown file in `specs/`

## Tips

- **Use N/A**: Empty optional fields default to "N/A" instead of "TBD"
- **File references**: Type `#` to quickly link to existing code, specs, or docs
- **ESC/Ctrl+D**: Exit multi-line inputs (gum write)
- **Markdown preview**: Open generated files in VS Code or any markdown viewer
- **Backup**: Old script backed up to `spec-wizard.tui.sh.bak`

## File Structure

```
specs/
  20260127-implement-login-validation.md
  20260128-fix-crash-on-background.md
  ...
```

## Template Details

### Form 1: New Feature Delivery
Comprehensive feature spec including:
- Problem statement, goals, business value
- Users, permissions, preconditions
- UX behavior (screens, entry/exit, inputs, actions, feedback)
- Business rules (validation, decision, ordering)
- Data requirements and integrations
- Edge cases and failure recovery
- Acceptance criteria and success metrics

### Form 2: Change Request
Documents changes to existing features:
- Current vs desired behavior
- What must remain unchanged (guardrails)
- Backward compatibility concerns
- Rollout notes (feature flags, incremental rollout)

### Form 3: Bug & Correctness
Structured bug reports:
- Severity, frequency, affected versions
- Reproduction steps
- Environment details (device, Android version, network)
- Evidence (screenshots, logs, sample data)
- Impact assessment and workarounds

### Forms 4-11
See the ticket forms document for complete field lists.

## Migration from Old Script

The new script replaces the original feature-spec-only wizard with:
- 11 template types instead of 1
- File reference support via `#` trigger
- N/A defaults instead of TBD
- Template-specific prompts and outputs
- Backup of old script at `spec-wizard.tui.sh.bak`


----

# BA → Senior Dev Ticket Forms (11 Types)

> Use **one form per ticket** (copy the matching section).  
> If a field doesn’t apply, write **N/A** (avoid “TBD”).

---

## 1) Form — New Feature Delivery

### Ticket header
- Title:
- Priority: P0 / P1 / P2 / P3
- Target release / deadline:
- Owner (BA):
- Stakeholders:

### Problem & goal
- Problem statement (current pain):
- Goal (what users can do after):
- Business value:
- Non-goals (explicitly out of scope):

### Users & permissions
- Primary users:
- Secondary users:
- Permission rules:
- Preconditions (login, entitlement, required setup):

### UX / behavior (not pixel-perfect)
- Screens involved:
- Entry points:
- Exit points (success / cancel-back):
- Draft/partial progress rule (save/discard/restore):
- Inputs (fields + constraints + exact validation messages):
- Actions (CTA enabled rules + double-submit prevention):
- Feedback (loading, success, error style, empty state):
- Accessibility/localization expectations (if any):

### Business rules
- Validation rules (with examples):
- Decision rules (if/then + examples):
- Ordering/dedup/idempotency rules (if any):

### Data & integrations (business view)
- Data inputs used:
- Data outputs shown:
- What must be saved + when:
- What must NOT be saved/logged (PII/security):
- External systems/APIs/SDKs involved:

### Edge cases & failure recovery
- Offline/timeout behavior:
- Retry rules:
- What happens on app background/kill:

### Acceptance criteria (Given/When/Then)
- AC-1:
- AC-2:
- AC-3:
- AC-4:
- AC-5:

### Success metrics (if applicable)
- Metric:
- Baseline:
- Target:
- How measured:

### Open questions
- Q1:
- Q2:

---

## 2) Form — Change Request to Existing Feature

### Ticket header
- Title:
- Priority:
- Target release:
- Owner (BA):
- Stakeholders:

### Change summary
- What is changing (1–2 lines):
- Why now:
- User impact:
- Business impact:

### Current vs desired behavior
- Current behavior:
- Desired behavior:
- What must remain unchanged (guardrails):
- Backward compatibility concerns (data/UI/API):

### UX / behavior changes
- Screens touched:
- Entry/exit changes:
- New/changed fields + validation messages:
- New/changed actions + enablement rules:
- Loading/success/error/empty state changes:

### Business rules changes
- Rules to add/change/remove:
- Examples before → after:

### Data impact
- Data added/modified/removed:
- Migration required? (yes/no/unknown):
- Reporting/analytics impact:

### Edge cases
- Scenarios that previously worked and must still work:
- New failure scenarios and recovery:

### Acceptance criteria
- AC-1 (covers old behavior preserved):
- AC-2 (covers new behavior):
- AC-3 (edge cases):

### Rollout notes (if needed)
- Feature flag needed? yes/no
- Incremental rollout? yes/no

---

## 3) Form — Bug & Correctness

### Ticket header
- Title:
- Severity: Critical / High / Medium / Low
- Frequency: Always / Often / Sometimes / Rare
- First seen (date/version):
- Affected versions/devices:
- Owner (BA):
- Stakeholders:

### Bug description
- What is broken (1–2 lines):
- Expected behavior:
- Actual behavior:

### Reproduction steps
1)
2)
3)

### Environment
- App version/build:
- Device model(s):
- Android version(s):
- Network condition (wifi/4G/offline):
- Account type/role:

### Evidence
- Screenshots/video:
- Logs (Crashlytics link, logcat snippet):
- Sample account/data to reproduce (if safe):

### Impact assessment
- User impact:
- Business impact:
- Workaround available? (yes/no + steps)

### Suspected cause (optional)
- Hypothesis:
- Recent changes possibly related:

### Acceptance criteria (fix verification)
- AC-1: Given ..., When ..., Then ...
- AC-2:
- AC-3:

---

## 4) Form — Feasibility / Design Consultation (Pre-implementation)

### Ticket header
- Title:
- Priority:
- Decision needed by (date):
- Owner (BA):
- Stakeholders:

### Business question
- What decision is needed:
- Why it matters:
- What happens if we delay:

### Proposed experience / requirement (high-level)
- What user should be able to do:
- Constraints (policy, privacy, budget, time):

### Options considered (BA view)
- Option A:
- Option B:
- Option C:
- What you need from senior dev:
  - feasibility risks
  - recommended approach
  - rough effort range
  - key dependencies

### Inputs to support decision
- Target users:
- Platforms/devices constraints:
- Non-goals:
- Integration constraints:

### Output expected from senior dev
- Recommended option + rationale:
- Key risks/edge cases:
- Spike/prototype needed? (yes/no)
- Follow-up tickets required:

---

## 5) Form — Integration & Dependencies (API/SDK/System)

### Ticket header
- Title:
- Priority:
- Target release:
- Owner (BA):
- Stakeholders:
- External owner/contact:

### Integration summary
- System/SDK/API to integrate:
- Business goal:
- User-facing change:

### Contract requirements (business-level)
- Data required from integration (fields + meaning):
- Data sent to integration (fields + meaning):
- Success criteria:
- Error behaviors (what user sees; retry rules):
- Rate limits / quotas (if known):

### Environments & access
- Sandbox/staging availability:
- Credentials process:
- IP allowlist / security steps:

### Dependencies & blockers
- Backend changes needed:
- Legal/compliance review needed:
- Vendor approvals needed:

### Rollout & compatibility
- Backward compatibility:
- Feature flag required?:
- Fallback if integration down:

### Acceptance criteria
- AC-1:
- AC-2:
- AC-3:

---

## 6) Form — Data & Analytics Request

### Ticket header
- Title:
- Priority:
- Target date:
- Owner (BA):
- Stakeholders (marketing, data, product):

### Business question
- What decision/report will this enable:
- Who uses it:
- Frequency (daily/weekly/ad-hoc):

### Events / tracking requirements
For each event:
- Event name:
- Trigger (exact moment):
- Properties (key → meaning):
- User identifiers allowed (PII rules):
- Expected volume (rough):

### Success metrics
- KPI definitions:
- Calculation rules:
- Source of truth (app vs backend):

### Validation plan
- How to verify events fire correctly:
- Sample scenarios to test:

### Acceptance criteria
- AC-1:
- AC-2:
- AC-3:

---

## 7) Form — Quality / Performance / Reliability

### Ticket header
- Title:
- Priority:
- Target release:
- Owner (BA):
- Stakeholders:

### Problem statement (with evidence)
- What is slow/unstable:
- Evidence (metrics, screenshots, videos, ANR/crash rate):
- Where it happens (screen/flow):

### Target improvement
- Metric name (startup time / jank / memory / crash-free):
- Baseline:
- Target:
- Measurement method (tool/source):

### Scope
- Affected flows/screens:
- Must-not-break areas:
- Non-goals:

### User experience requirements
- What user should feel/see after improvement:
- Loading/retry behavior expectations:

### Acceptance criteria
- AC-1: baseline → target met
- AC-2: no regression in X
- AC-3: monitoring added/updated (if needed)

---

## 8) Form — Security / Privacy / Compliance

### Ticket header
- Title:
- Priority:
- Deadline (legal/compliance):
- Owner (BA):
- Stakeholders (security/legal):

### Driver
- Policy/regulation reference (if any):
- Risk description (what could go wrong):

### Data classification
- Data involved:
- Is it PII/sensitive?:
- Where it appears (UI/logs/storage/network):

### Required controls (business requirements)
- Consent requirements:
- Masking/redaction rules:
- Retention/deletion rules:
- Access control rules:
- Encryption requirements (at rest/in transit) if mandated:

### UX requirements
- User-facing copy (exact text):
- Settings/toggles needed:
- Error handling if user denies consent:

### Audit requirements
- What must be recorded (who/what/when):
- Export/report needs:

### Acceptance criteria
- AC-1:
- AC-2:
- AC-3:

---

## 9) Form — Release / Operations (Rollout, Hotfix, Monitoring)

### Ticket header
- Title:
- Priority:
- Release window:
- Owner (BA):
- Stakeholders (support/ops):

### Request type
- Hotfix / phased rollout / enable feature flag / rollback support / monitoring change

### Context
- What is being released/changed:
- Why now:
- Risk level:

### Rollout plan (business-level)
- Rollout strategy (phased/100%):
- Target audience:
- Kill switch required?:
- Fallback behavior if issues occur:

### Monitoring & support
- Metrics to monitor:
- Alert thresholds (if any):
- Support instructions (what to tell users):
- Known issues + workaround:

### Acceptance criteria
- AC-1:
- AC-2:
- AC-3:

---

## 10) Form — Tech Debt / Maintainability (BA-triggered)

### Ticket header
- Title:
- Priority:
- Target window:
- Owner (BA):
- Stakeholders:

### Why this matters (from BA/product perspective)
- What changes are hard today:
- Cost of not fixing (time, bugs, missed deadlines):
- What feature work is blocked/slow because of this:

### Desired outcome (not implementation)
- What should become easier/faster:
- What quality should improve (testability, modularity):
- Non-goals (no big rewrites beyond scope):

### Scope boundaries
- Areas to refactor:
- Areas not to touch:
- Risk areas:

### Acceptance criteria (business-level)
- AC-1: future change X becomes possible within Y effort (estimate)
- AC-2: regression risk reduced via tests/monitoring
- AC-3: documentation updated (if needed)

---

## 11) Form — AI-era Workflow / Guardrails (BA + Senior Dev)

### Ticket header
- Title:
- Priority:
- Target date:
- Owner (BA):
- Stakeholders (dev lead, QA):

### Problem statement
- What AI/codegen is doing wrong:
- Examples (paste snippets or links):
- Impact (bugs, rework, slow reviews):

### Desired guardrails
- What must be enforced (rules):
- Forbidden patterns:
- Required patterns:
- Definition of Done checks (what CI should fail on):

### Inputs & outputs
- Inputs (spec format, templates, prompts):
- Output artifacts expected (tests, docs, file structure):
- Where it should be integrated (pre-commit/CI/PR checks):

### Acceptance criteria
- AC-1: Given a violating change, CI fails with clear message
- AC-2: Given a compliant change, passes
- AC-3: reduces review time or defect rate (metric)

### Example “good vs bad”
- Good example:
- Bad example:
