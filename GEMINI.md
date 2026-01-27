# Gemini Project Context: BluePrint Android

This document provides a comprehensive overview of the "BluePrint Android" project for AI-driven development.

## 1. Project Overview

This is a **Clean Architecture Android template** designed for modern Android development. It emphasizes high code quality through a comprehensive set of "quality guardrails" that are strictly enforced.

The core purpose is to provide a production-ready foundation for new Android projects, incorporating best practices and a clear, scalable structure.

### Key Technologies:
*   **UI:** Jetpack Compose
*   **Architecture:** MVVM (Model-View-ViewModel), Unidirectional Data Flow (UDF)
*   **Asynchronicity:** Kotlin Coroutines & Flow
*   **Dependency Injection:** Hilt (from Dagger)
*   **Database:** Room (with auto-migrations)
*   **Build System:** Gradle

## 2. Building, Running, and Testing

The project uses Gradle for all build, test, and verification tasks. The `gradlew` wrapper script is included in the repository.

### Primary Command: The Quality Gate

The most important command is `qualityCheck`. It runs a full suite of verification tasks and is the main quality gate for the CI pipeline.

```bash
# Run all quality checks: formatting, static analysis, lint, and unit tests
./gradlew :app:qualityCheck
```

This single command executes:
1.  `spotlessCheck`: Checks for code formatting issues.
2.  `detekt`: Runs static analysis against the rules in `detekt.yml`.
3.  `lintDebug`: Executes Android Lint checks.
4.  `testDebugUnitTest`: Runs all unit tests, including architectural tests.

### Other Key Commands:

*   **Build the project:**
    ```bash
    ./gradlew build
    ```

*   **Apply code formatting:**
    ```bash
    ./gradlew spotlessApply
    ```

*   **Run all unit tests:**
    ```bash
    ./gradlew :app:testDebugUnitTest
    ```

*   **Run instrumentation tests:**
    ```bash
    ./gradlew :app:connectedAndroidTest
    ```

*   **Run only architecture tests:**
    ```bash
    ./gradlew :app:testDebugUnitTest --tests "*ArchitectureTest"
    ```

*   **Assemble a debug APK:**
    ```bash
    ./gradlew assembleDebug
    ```

## 3. Development Conventions & Quality Guardrails

This project enforces a "zero tolerance" policy for quality violations. Rules are enforced at multiple levels: pre-commit hooks, the build process, and the CI pipeline.

### Source Code Conventions:
*   **Formatting:** Handled by `spotless` with `ktlint`. Max line length is 120 characters. No wildcard imports.
*   **Static Analysis:** Handled by `detekt` with rules defined in `detekt.yml`. Key rules include:
    *   **No `!!` (non-null assertions).** Use safe calls (`?.`), `let`, or other idiomatic Kotlin constructs.
    *   **No `GlobalScope` for coroutines.** Use `viewModelScope`, `lifecycleScope`, or inject a `CoroutineDispatcher`.
    *   **No `println()` or `printStackTrace()`.** Use a proper logging library (not yet implemented, but the rule is enforced).
    *   **Complexity limits:** Functions and classes are kept under strict complexity thresholds.

### Architectural Rules (enforced by ArchUnit):
*   **Clean Architecture Boundaries:**
    *   The `data` layer **must not** depend on the `ui` layer.
*   **MVVM Pattern Enforcement:**
    *   ViewModels **must not** hold a reference to or depend on a `NavController`. Navigation should be handled by the UI layer, observing state from the ViewModel.
    *   All ViewModels **must be** annotated with `@HiltViewModel`.

### Pre-commit Hook:
A `pre-commit` hook (located in the root directory) automatically runs on every commit to check for the most common violations (e.g., `!!`, `GlobalScope`, formatting issues), preventing them from entering the codebase.

To install it:
```bash
cp pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## 4. Project Structure

The project follows a standard Gradle structure with a single `app` module. The application code is organized by feature and layer.

```
app/src/main/java/com/devindie/blueprint/
├── data/                           # Data Layer (Repositories, Data Sources)
│   ├── di/                         # Hilt modules for the data layer
│   └── local/                      # Room database components
├── di/                             # App-level Hilt modules
├── ui/                             # UI Layer (Compose Screens, ViewModels)
│   ├── mainscreen/                 # Example feature package
│   │   ├── MainScreenScreen.kt     # Composable UI
│   │   └── MainScreenViewModel.kt  # ViewModel for the screen
│   └── theme/                      # Jetpack Compose Theme
├── BluePrint.kt                    # Application class with @HiltAndroidApp
└── MainActivity.kt                 # Single entry point Activity
```
