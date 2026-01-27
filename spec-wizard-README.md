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
