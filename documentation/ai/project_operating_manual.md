# Project Operating Manual (POM) — Android/Kotlin (Compose + Hilt, Single Module, Feature Packages)
> **AI instruction:** Follow this POM strictly. If anything conflicts with it or info is missing, STOP and propose options before writing code.

---

## 1) Project Snapshot
- **App name:** <AppName>
- **Repo:** <RepoName/Link>
- **Min/Target SDK:** <MinSdk> / <TargetSdk>
- **UI:** Jetpack Compose
- **DI:** Hilt (Dagger)
- **Module setup:** Single module
- **Architecture:** MVVM (feature-based packages)

---

## 2) Package Layout (Must Respect)
- `[featurename]/` (feature)
  - `[Feature]ViewModel.kt`
  - `[Feature]Screen.kt`
  - Optional: UI component files inside feature package (e.g., `components/`, or `FeatureComponents.kt`)
- `data/` (shared data layer)
- `di/` (Hilt modules)
- `util/` (shared utils)
- Root:
  - `[AppName]Activity.kt`
  - `[AppName]Application.kt`
  - `[AppName]NavGraph.kt`
  - `[AppName]Navigation.kt`
  - `[AppName]Theme.kt`

**Rule:** Any new code must be placed in the correct package above. Do not invent new top-level packages unless requested.

---

## 3) Non-Negotiable Team Rules (Hard Stops)
1. **No business logic in Composables**. Composables render state + forward user intents only.
2. **Screens never call `data/` directly.** UI → ViewModel → (data) Repository.
3. **DI via Hilt only.** No manual singletons, no service locator patterns in UI. No `KoinComponent` usage.
4. **No new architectural patterns** without proposing options first.
5. **No new dependencies** unless explicitly requested.
6. **No blocking work on Main.** Use coroutines; use IO dispatcher for I/O.
7. **No `!!`**.
8. **No hardcoded user-visible strings.** Use `strings.xml`.
9. **Every screen must cover loading/empty/error states** (as applicable).
10. **Every Acceptance Criterion must map to tests** (or documented manual steps if tests are not set up).

---

## 4) MVVM Contract (Compose)
### Screen responsibilities (`[Feature]Screen.kt`)
- Collect and render `UiState`
- Call `viewModel.onEvent(...)` (preferred) or explicit VM functions
- Observe one-off effects (snackbar/navigation) via `LaunchedEffect`

### ViewModel responsibilities (`[Feature]ViewModel.kt`)
- Expose immutable `StateFlow<UiState>`
- Handle `UiEvent` and update state
- Call repositories/services in `data/`
- Map failures to UI-friendly errors/messages
- Emit one-off effects (navigation/snackbar) via `SharedFlow/Channel` when needed

**No-go:** Business logic, data fetching, validation rules in Composables.

---

## 5) Standard UI State / Event / Effect Pattern (Recommended)
> Use these as needed; keep it simple for small features.

- `UiState`: `data class` (or `sealed interface` for multi-mode screens)
- `UiEvent`: `sealed interface` for user intents
- `UiEffect`: `sealed interface` for one-off actions (toast/snackbar/nav)

**Minimum state fields (typical):**
- `isLoading: Boolean`
- `error: UiError?` (or `StringRes` message id)
- `data: <Type?>` (or `items: List<X>`)

---

## 6) Navigation Standard (Centralized)
- Navigation code must live in:
  - `[AppName]NavGraph.kt` and/or `[AppName]Navigation.kt`
- Feature screens accept navigation callbacks as lambdas:
  - `onBack()`, `onOpenDetail(id)`, etc.
- ViewModel must **not** depend on `NavController`.
  - If navigation is triggered by logic: ViewModel emits `UiEffect.Navigate(route)` and Screen performs navigation.

---

## 7) Hilt DI Standard
- All DI modules live in `di/` packages (can be feature-specific or shared)
- Modules use `@Module` + `@InstallIn(SingletonComponent::class)` (or other components as needed)
- ViewModels:
  - Annotated with `@HiltViewModel`
  - Use constructor injection with `@Inject`
  - Screens obtain ViewModels via `hiltViewModel()` composable
- Repositories/Services:
  - Prefer `@Binds` for interface → implementation bindings (requires `interface` module)
  - Use `@Provides` for concrete instance provision (requires `class` module)
  - Mark app-scoped instances with `@Singleton`
- Application class must be annotated with `@HiltAndroidApp`
- Testing:
  - Test modules use `@TestInstallIn` with `replaces = [OriginalModule::class]`
  - Fake implementations should live in production module for reusability

**Rule:** If a new ViewModel/Repo is created, DI must be updated in the same change.

---

## 8) Data Layer Standard (`data/`)
- Shared repositories, data sources, mappers live here.
- Prefer clean boundaries:
  - Repository interface (optional)
  - Repository implementation
  - Local/remote sources (if any)
  - Mapping functions

**Error handling rule:** Repositories should return predictable results (sealed result type or mapped errors). Avoid leaking exceptions to UI.

---

## 9) Quality Bars
### Loading / Empty / Error
- Every screen must define:
  - loading UI
  - empty state UI (if list/collection)
  - error UI (message + retry action)

### Performance
- No heavy work on Main
- Avoid recomposition traps (stable params, derivedStateOf when appropriate)

### Strings
- All user-visible strings in `strings.xml`

---

## 10) Testing Standard
Minimum expectation per feature:
- ViewModel unit tests for key state transitions (success/failure/user actions)
- If tests are not set up, AI must:
  - provide manual test steps mapped to AC
  - and propose a minimal test setup plan (without adding deps unless requested)

---

## 11) Definition of Done (DoD)
- [ ] Acceptance Criteria met
- [ ] Navigation updated in `[AppName]NavGraph.kt` / `[AppName]Navigation.kt`
- [ ] Hilt DI updated in `di/` (modules properly annotated)
- [ ] Loading/empty/error covered
- [ ] No hardcoded strings
- [ ] No new warnings
- [ ] Tests added OR manual test steps documented

---

## 12) AI Output Format (Mandatory)
When you (AI) generate work, you MUST:
1. Start with **Scope confirmation** (what you will implement + what you won’t).
2. Provide a **Plan**: files to modify/create (matching package layout).
3. Output code **file-by-file** with exact filenames + package declarations.
4. Add tests (or manual test steps if tests aren’t available).
5. End with **Self-review**:
   - rule violations?
   - missing edge cases/states?
   - test gaps?

---

## 13) Feature Brief Template (Paste per request)
**Requirement (from PO):** <paste>

**Goal:**  
**In scope:**  
**Out of scope:**  
**User flow:**  
**Edge cases:**  
**Acceptance criteria:**  
**Open questions:**  
**Assumptions:**  

---
