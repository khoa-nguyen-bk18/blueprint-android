# BluePrint Android Architecture - AI Agent Instructions

## Overview
BluePrint is a modern Android application demonstrating clean architecture with Kotlin, Jetpack Compose, Room database, and Hilt dependency injection. The codebase follows a unidirectional data flow pattern with separate data, domain, and UI layers.

## Architecture Pattern: MVVM + Clean Architecture

**Core Structure:**
- **UI Layer** (`ui/`): Compose screens and ViewModels with reactive StateFlow
- **Data Layer** (`data/`): Repository interfaces and Room database DAOs
- **DI Layer**: Hilt modules for dependency injection

**Data Flow:**
UI Screen → ViewModel → Repository → Room Database (Flow-based reactive updates)

## Key Patterns & Conventions

### 1. Repository Pattern
Repositories expose data as `Flow<T>` for reactive updates. Always use:
```kotlin
interface MainScreenRepository {
    val mainScreens: Flow<List<String>>
    suspend fun add(name: String)
}
```
- Repository interfaces define contracts in [data/](app/src/main/java/com/devindie/blueprint/data/)
- Implementations inject DAOs and transform data using Flow operators like `map()`
- Test implementations (Fake*) should be in the same module for unit tests

### 2. ViewModel UI State Management
ViewModels transform repository flows into `StateFlow<UiState>`:
```kotlin
@HiltViewModel
class MainScreenViewModel @Inject constructor(
    private val mainScreenRepository: MainScreenRepository
) : ViewModel() {
    val uiState: StateFlow<MainScreenUiState> = mainScreenRepository
        .mainScreens.map<List<String>, MainScreenUiState>(::Success)
        .catch { emit(Error(it)) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), Loading)
}
```
- Sealed interfaces for UI state (Loading, Success, Error)
- Use `collectAsStateWithLifecycle()` in Composables to safely collect
- Leverage `viewModelScope.launch {}` for suspend operations

### 3. Compose Screen Structure
Screens follow a two-composable pattern:
- **Stateful outer composable**: Collects ViewModel state using `hiltViewModel()`
- **Stateless inner composable**: Renders UI and accepts callbacks

```kotlin
@Composable
fun MainScreenScreen(modifier: Modifier = Modifier, viewModel: MainScreenViewModel = hiltViewModel()) {
    val items by viewModel.uiState.collectAsStateWithLifecycle()
    if (items is MainScreenUiState.Success) {
        MainScreenScreen(items = (items as MainScreenUiState.Success).data, onSave = viewModel::addMainScreen)
    }
}
```

### 4. Dependency Injection with Hilt
- **@HiltAndroidApp** on Application class ([BluePrint.kt](app/src/main/java/com/devindie/blueprint/BluePrint.kt))
- **@Module + @InstallIn** for DI modules:
  - [DataModule.kt](app/src/main/java/com/devindie/blueprint/data/di/DataModule.kt): Repository bindings
  - [DatabaseModule.kt](app/src/main/java/com/devindie/blueprint/data/local/di/DatabaseModule.kt): Room database provision
- **@Singleton** for app-wide instances (AppDatabase)
- Use `@Binds` for interface bindings (preferred over `@Provides` when possible)

### 5. Room Database with Auto-Migrations
- Entities: [MainScreen.kt](app/src/main/java/com/devindie/blueprint/data/local/database/MainScreen.kt)
- DAOs: Define in [database/](app/src/main/java/com/devindie/blueprint/data/local/database/)
- Database class: [AppDatabase.kt](app/src/main/java/com/devindie/blueprint/data/local/database/AppDatabase.kt)
- Schema stored in `app/schemas/` for migration tracking

## Testing Strategy

### Unit Tests (test/)
- Test ViewModels with fake repositories
- Use `runTest {}` (kotlinx-coroutines-test) for coroutine testing
- Create Fake* implementations that satisfy repository interfaces

### Instrumented Tests (androidTest/)
- Use `HiltTestRunner` in [HiltTestRunner.kt](app/src/androidTest/java/com/devindie/blueprint/HiltTestRunner.kt)
- Replace production modules with test variants using `@TestInstallIn` in [TestDatabaseModule.kt](app/src/androidTest/java/com/devindie/blueprint/testdi/TestDatabaseModule.kt)
- Test Compose UI with Navigation tests

## Build & Dependencies

**Build System:** Gradle with Kotlin DSL  
**Target Versions:** Kotlin 2.2.21, minSdk 23, targetSdk 36, Java 17

**Critical Dependencies:**
- **Compose BOM**: 2025.11.01 (unified versions from [libs.versions.toml](gradle/libs.versions.toml))
- **Hilt**: 2.57.2 with KSP annotation processing
- **Room**: 2.8.4 (with auto-migrations enabled)
- **Navigation Compose**: 2.9.6 for screen routing
- **Coroutines**: 1.10.2 with test support

**Key Gradle Plugins:** KSP (annotation processing), Compose Compiler, Hilt Gradle Plugin

## Development Workflow

1. **Generate New Screens:** Run customizer script (example: `bash customizer.sh com.devindie.blueprint MainScreen BluePrint`)
2. **Build:** `./gradlew build`
3. **Run Tests:** 
   - Unit: `./gradlew test`
   - Instrumented: `./gradlew connectedAndroidTest`

## Files to Reference When Adding Features

- **New data source?** → Follow pattern in [MainScreenRepository.kt](app/src/main/java/com/devindie/blueprint/data/MainScreenRepository.kt)
- **New screen?** → Copy structure from [mainscreen/](app/src/main/java/com/devindie/blueprint/ui/mainscreen/)
- **DI changes?** → Consult [DataModule.kt](app/src/main/java/com/devindie/blueprint/data/di/DataModule.kt) and [DatabaseModule.kt](app/src/main/java/com/devindie/blueprint/data/local/di/DatabaseModule.kt)
- **Database migration?** → Update entity version in [AppDatabase.kt](app/src/main/java/com/devindie/blueprint/data/local/database/AppDatabase.kt)
