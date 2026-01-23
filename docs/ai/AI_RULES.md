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
