# AI Context Pack

- Repo: blueprint-android
- Branch: feature/cameraqr
- Commit: 2674fc2

## AI Protocol
### .ai/prompts/MASTER_PROMPT.md
```
You are my Android coding agent. You MUST follow this protocol:

1) Read docs/ai/* and summarize the coding rules + architecture in 8–12 bullets.
2) Produce: Abstract → Flow → UI plan.
3) Produce a Change Contract listing exact files to modify/create and commands that must pass.
4) DO NOT write code until I reply with APPROVE_CONTRACT.
5) Prefer modifying existing code before creating new files. Creating new files requires justification.
6) Work in small slices (3–6 files). After each slice, run tools/check-fast.sh and fix failures.
7) You must not touch files not listed in the Change Contract / allowlist. If needed, revise contract first.
8) Final output: file-by-file summary + confirmation of passed checks + updated Session Snapshot content.
```

## Project Rules
### docs/ai/AI_RULES.md
```
# AI Rules (Android Native)

This repository uses an **AI-assisted development protocol**. Any AI-generated change MUST follow these rules.

## 0) Non-negotiables
- **No code generation before an approved Change Contract.**
- **Prefer modifying existing code** over creating new files/classes.
- **No architectural drift**: do not introduce new patterns/frameworks without an explicit decision recorded in `.ai/decisions.md`.
- **Tool-truth**: changes are considered valid only if required checks pass.

## 1) Architecture boundaries (MVVM recommended)
> Adjust this section to your exact architecture. If your project already has a structure, FOLLOW IT.

- **UI layer**: Jetpack Compose screens/components, navigation, UI state rendering.
- **ViewModel layer**: state machine, input events, business orchestration, calls into domain/data.
- **Domain layer (optional)**: pure Kotlin use-cases, entities, business rules.
- **Data layer**: repositories, network, persistence (Room/DataStore), DTO <-> model mapping.

Rules:
- UI must not call network/database directly.
- ViewModels must not hold Android `Context` unless explicitly justified (and testability is preserved).
- Keep side effects behind interfaces where possible (repositories, data sources).

## 2) File placement rules
- New UI screens go under the existing feature package/module.
- ViewModels live next to their screens (feature-based) **or** in `presentation/` (if that exists).
- Repositories and data sources live in `data/` (or your existing location).
- DI modules live in your DI folder/module.

## 3) Naming conventions
- Screen composables: `FeatureNameScreen`
- ViewModels: `FeatureNameViewModel`
- UI state: `FeatureNameUiState`
- UI events/intents: `FeatureNameUiEvent` or `FeatureNameIntent`

## 4) Error handling
- Model failures explicitly (sealed `Result`, `Either`, or exception mapping).
- UI state must represent error/empty/loading explicitly.
- Log only with approved logger (e.g., Timber) if present; avoid leaking PII.

## 5) Testing expectations
Minimum for each feature change:
- ViewModel state transitions unit tests.
- Data mapping tests if new mapping introduced.

Prefer:
- Pure Kotlin tests where possible.
- Deterministic tests (no sleeps, no real network).

## 6) Performance & Compose rules (if using Compose)
- Avoid heavy work in Composables; move to ViewModel.
- Remember stable state; avoid unnecessary recompositions.
- Use `Lazy*` for large lists.

## 7) Change Contract protocol
Any AI session MUST:
1. Read `docs/ai/*` and summarize constraints.
2. Produce Abstract → Flow → UI plan.
3. Produce a Change Contract listing exact files to modify/create.
4. Wait for `APPROVE_CONTRACT` before editing code.
5. Work in small slices; after each slice, run `tools/check-fast.sh` and fix failures.
```

### docs/ai/PROJECT_MAP.md
```
# Project Map

Update this file once so AI can consistently place code correctly.

## Modules
- `:app` — Android application module (UI, navigation, DI bootstrap)

## Package layout
- `com.devindie.blueprint`
  - `ui/<feature>/` — screen + ViewModel + UI state
  - `data/` — repositories, data sources, Room
  - `di/` — Hilt modules
  - `navigation/` — NavGraph, routes

## Key entry points
- Application class: `com.devindie.blueprint.BluePrint`
- Main activity: `com.devindie.blueprint.MainActivity`
- Navigation graph: `com.devindie.blueprint.navigation.MainNavigation`
- DI modules: `di/DataModule.kt`, `di/DatabaseModule.kt`

## Golden examples
Point AI to your best implementations:
- Best ViewModel: `ui/mainscreen/MainScreenViewModel.kt`
- Best Screen: `ui/mainscreen/MainScreenScreen.kt`
- Best Repository: `data/MainScreenRepository.kt`
```

### docs/ai/DEFINITION_OF_DONE.md
```
# Definition of Done (Android)

A change is "done" only when:

## Required
- Change Contract approved and followed (no files outside allowlist).
- `tools/check-fast.sh` passes locally.
- CI passes `tools/check.sh`.
- Feature acceptance criteria satisfied.
- No new files unless justified and recorded in the Change Contract.

## Recommended
- ViewModel unit tests for new/changed state logic.
- If UI behavior changes significantly, add Compose UI tests.
- Update docs if architecture decisions change (`.ai/decisions.md`).
```

### docs/ai/GOLDEN_EXAMPLES.md
```
# Golden Examples

Add links/paths to 2–4 "best in repo" examples so AI copies patterns instead of inventing new ones.

## UI
- `app/src/main/java/com/devindie/blueprint/ui/mainscreen/MainScreenScreen.kt`

## ViewModel
- `app/src/main/java/com/devindie/blueprint/ui/mainscreen/MainScreenViewModel.kt`

## Data / Repository
- `app/src/main/java/com/devindie/blueprint/data/MainScreenRepository.kt`

## Testing
- `app/src/test/java/com/devindie/blueprint/ui/mainscreen/MainScreenViewModelTest.kt`
```

## Latest Session (if any)
### .ai/sessions/2026-01-25__splashscreen.md
```
# Session: YYYY-MM-DD — Feature: <name>

## Goal
- ...

## Current Status
- Phase: Abstract | Flow | UI | Contract Approved | Slice N | Validation | Done
- Last checkpoint commit: <hash>
- Last stable checks: check-fast PASS, check PASS

## Approved Change Contract (LOCKED)
### Modify
- path:
### Create
- path:
### No-touch
- ...
### Must pass
- tools/check-fast.sh
- tools/check.sh

## Decisions (why)
- Decision:
  - Rationale:
  - Alternatives:

## Work Done (chronological)
1) Slice 1 — ...
   - Commit(s):
2) Slice 2 — ...
   - Commit(s):

## Command Outputs (paste failures here)
- check-fast:
- check:

## Next Steps (exact)
1) ...
2) ...

## Resume Prompt (paste into AI)
Read docs/ai/*.
Last checkpoint: <hash>.
Current phase: <...>.
Contract: (paste).
Next steps: (paste).
Do not touch files outside allowlist/contract without revising contract.
```

## Git Status
```
 M .ai/context/AI_CONTEXT.md
?? .ai/sessions/2026-01-25__splashscreen.md
?? docs/20260125-splash-screen.md
?? tools/spec-wizard.tui.sh
```
