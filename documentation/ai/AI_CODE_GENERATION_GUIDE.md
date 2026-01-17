# BluePrint Android - Comprehensive AI Code Generation Guide

**Last Updated:** January 17, 2026  
**Version:** 1.0  
**Status:** Production Ready (Zero Violations)

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture & Patterns](#architecture--patterns)
3. [Code Style & Formatting](#code-style--formatting)
4. [Quality Guardrails (Enforced)](#quality-guardrails-enforced)
5. [File Structure](#file-structure)
6. [DI with Hilt](#di-with-hilt)
7. [MVVM & Compose Patterns](#mvvm--compose-patterns)
8. [Repository & Data Layer](#repository--data-layer)
9. [Naming Conventions](#naming-conventions)
10. [Testing Standards](#testing-standards)
11. [Development Commands](#development-commands)
12. [Code Examples](#code-examples)

---

## Project Overview

**Application:** BluePrint Android  
**Package Name:** `com.devindie.blueprint`  
**Architecture:** Clean Architecture + MVVM  
**UI Framework:** Jetpack Compose  
**DI Framework:** Hilt (Dagger)  
**Database:** Room with auto-migrations  
**Min SDK:** 23 | Target SDK: 36 | Kotlin: 2.2.21

### Core Principles

1. **Unidirectional Data Flow:** UI → ViewModel → Repository → Database
2. **Single Responsibility:** Each layer has one job
3. **Testability:** All code must be testable (no God classes)
4. **Clean Slate:** ZERO violations allowed - enforced automatically
5. **Documentation:** Code should be self-documenting with clear naming

---

## Architecture & Patterns

### Layer Boundaries

```
┌─────────────────────────────────────┐
│         UI Layer (Compose)          │  - Screens, ViewModels
│    (can only access ViewModel)      │
└────────────────────┬────────────────┘
                     │
┌────────────────────▼────────────────┐
│       ViewModel Layer (MVVM)        │  - State management
│  (can access Repository interface)  │
└────────────────────┬────────────────┘
                     │
┌────────────────────▼────────────────┐
│         Data Layer                  │  - Repositories, DAOs
│   (never touches UI, uses Flow)     │
└────────────────────┬────────────────┘
                     │
┌────────────────────▼────────────────┐
│      Local Layer (Room)             │  - Database, Entities
└─────────────────────────────────────┘
```

### Key Rules

- ✅ **Screens NEVER directly import data layer**
- ✅ **ViewModels expose immutable StateFlow<UiState>**
- ✅ **Repositories return Flow<T> for reactive updates**
- ✅ **All DI happens in di/ packages via Hilt**
- ✅ **No manual singletons or service locators**
- ✅ **No business logic in Composables**

---

## Code Style & Formatting

### Spotless + ktlint Rules

**Command to auto-fix:** `./gradlew spotlessApply`

#### Line Length
- **Maximum:** 120 characters
- **Action:** Spotless enforces with `spotlessCheck`

#### Imports
- ❌ **Wildcard imports forbidden** (`import package.*`)
- ✅ Explicit imports required
- ✅ Organized alphabetically (handled by Spotless)

#### Indentation
- **Size:** 4 spaces (no tabs)
- **Trailing commas:** Allowed and encouraged (Kotlin style)
- **IDE:** Configure in `.editorconfig`

#### Function Formatting

```kotlin
// ✅ GOOD - Proper line breaks and alignment
fun complexFunction(
    parameterOne: String,
    parameterTwo: Int,
    parameterThree: Boolean,
): String {
    return when {
        parameterOne.isEmpty() -> "empty"
        parameterTwo > 0 -> "positive"
        else -> "other"
    }
}

// ❌ BAD - Long line exceeds 120 chars
fun complexFunction(parameterOne: String, parameterTwo: Int, parameterThree: Boolean): String = when { ... }
```

#### File Organization

```kotlin
// 1. Copyright header (auto-maintained)
/*
 * Copyright (C) 2022 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * ...
 */

// 2. Package declaration
package com.devindie.blueprint.ui.mainscreen

// 3. Imports (explicit, no wildcards)
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle

// 4. Class/Interface declaration
@Composable
fun MainScreenScreen(modifier: Modifier = Modifier) {
    // ...
}
```

---

## Quality Guardrails (Enforced)

### ❌ ABSOLUTELY FORBIDDEN (Build Fails)

#### 1. Non-null Assertions (`!!`)
```kotlin
// ❌ FORBIDDEN - Detekt + Pre-commit will reject
val value = nullableValue!!

// ✅ GOOD - Use safe calls
val value = nullableValue?.toString() ?: "default"

// ✅ GOOD - Use let
nullableValue?.let { v ->
    println(v)
}

// ✅ GOOD - Use require()
require(nullableValue != null) { "Value must not be null" }
```

#### 2. GlobalScope Usage
```kotlin
// ❌ FORBIDDEN - Detekt will reject
GlobalScope.launch {
    // This will fail build
}

// ✅ GOOD - Use viewModelScope (ViewModels)
class MyViewModel : ViewModel() {
    fun doSomething() {
        viewModelScope.launch {
            // Proper scope
        }
    }
}

// ✅ GOOD - Use lifecycleScope (Compose)
LaunchedEffect(Unit) {
    // Proper scoping in Compose
}
```

#### 3. println() and printStackTrace()
```kotlin
// ❌ FORBIDDEN - Detekt + Pre-commit will reject
println("Debug message")
exception.printStackTrace()

// ✅ GOOD - Use proper logging (or remove for production)
// Use Timber or Logcat wrapper if logging is needed
// For development, just remove debug code before commit
```

#### 4. Hardcoded Strings in UI
```kotlin
// ❌ FORBIDDEN - Android Lint error
Text("Save")
Text("Saved item: $value")

// ✅ GOOD - Use stringResource
Text(stringResource(R.string.save_button))
Text(stringResource(R.string.saved_item, value))

// Define in strings.xml:
// <string name="save_button">Save</string>
// <string name="saved_item">Saved item: %1$s</string>
```

### ⚠️ WARNINGS (May block merge)

#### Complexity Rules
```kotlin
// ❌ HIGH COMPLEXITY - Detekt warns
fun complexLogic(a: Int, b: Int, c: Int, d: Int): Boolean {
    return if (a > 0) {
        if (b > 0) {
            if (c > 0) {
                if (d > 0) {
                    true
                } else false
            } else false
        } else false
    } else false
}

// ✅ BETTER - Max cyclomatic complexity: 15
fun complexLogic(a: Int, b: Int, c: Int, d: Int): Boolean {
    return a > 0 && b > 0 && c > 0 && d > 0
}
```

#### Function Length
```kotlin
// ❌ TOO LONG - Detekt warns if > 60 lines
fun doTooMuch() {
    // 61+ lines of code
}

// ✅ GOOD - Break into smaller functions
fun doMainTask() {
    prepareData()
    processData()
    saveResults()
}

private fun prepareData() { }
private fun processData() { }
private fun saveResults() { }
```

#### Class Size
```kotlin
// ❌ TOO LARGE - Detekt warns if > 600 lines
class DoEverythingViewModel : ViewModel() {
    // 601+ lines
}

// ✅ GOOD - Separate concerns
class MainViewModel : ViewModel() { }
class DetailViewModel : ViewModel() { }
```

### ✅ Enforced by CI Pipeline

**Command:** `./gradlew :app:qualityCheck`

This runs (in order):
1. **spotlessCheck** - Formatting
2. **detekt** - Static analysis
3. **lintDebug** - Android-specific checks
4. **testDebugUnitTest** - Unit tests (including ArchUnit)

**Result:** ❌ FAILS BUILD if ANY check fails

---

## File Structure

### Package Organization

```
com/devindie/blueprint/
│
├── BluePrint.kt
│   └── @HiltAndroidApp Application class
│
├── ui/                           # UI Layer
│   ├── MainActivity.kt
│   ├── Navigation.kt             # NavGraph definition
│   │
│   ├── mainscreen/               # Feature package
│   │   ├── MainScreenScreen.kt   # Stateful + Stateless Composables
│   │   ├── MainScreenViewModel.kt
│   │   └── components/           # Optional: Shared components
│   │
│   └── theme/
│       ├── Color.kt
│       ├── Theme.kt
│       └── Type.kt
│
├── data/                         # Data Layer
│   ├── MainScreenRepository.kt   # Interface + DefaultImpl
│   │
│   ├── di/
│   │   └── DataModule.kt         # Repository bindings (@Binds)
│   │
│   └── local/
│       ├── database/
│       │   ├── AppDatabase.kt    # Room database
│       │   ├── MainScreen.kt     # Entity
│       │   └── MainScreenDao.kt  # DAO
│       │
│       └── di/
│           └── DatabaseModule.kt # Database bindings (@Provides)
│
└── util/                         # Shared utilities (optional)
    └── Extensions.kt
```

### New Feature Template

When adding a new feature `<FeatureName>`:

```
ui/
└── <featurename>/
    ├── <FeatureName>Screen.kt        # Composables
    ├── <FeatureName>ViewModel.kt     # @HiltViewModel
    └── components/                   # Optional

data/
└── <FeatureName>Repository.kt        # Interface + Impl

di/
└── <FeatureName>Module.kt            # Bindings

res/values/
└── strings.xml                       # Add strings
```

---

## DI with Hilt

### ✅ REQUIRED: All ViewModels must use @HiltViewModel

```kotlin
// ✅ CORRECT - Hilt pattern
@HiltViewModel
class MainScreenViewModel @Inject constructor(
    private val mainScreenRepository: MainScreenRepository,
) : ViewModel() {
    // DI happens automatically
}
```

### ✅ Repository Interface + Implementation

```kotlin
// In data/MainScreenRepository.kt

interface MainScreenRepository {
    val mainScreens: Flow<List<String>>
    suspend fun add(name: String)
}

class DefaultMainScreenRepository @Inject constructor(
    private val mainScreenDao: MainScreenDao,
) : MainScreenRepository {
    override val mainScreens: Flow<List<String>> =
        mainScreenDao.getAllAsFlow()

    override suspend fun add(name: String) {
        mainScreenDao.insert(MainScreen(name = name))
    }
}
```

### ✅ Repository Binding Module

```kotlin
// In data/di/DataModule.kt

@Module
@InstallIn(SingletonComponent::class)
interface DataModule {
    @Singleton
    @Binds
    fun bindsMainScreenRepository(
        impl: DefaultMainScreenRepository,
    ): MainScreenRepository
}
```

### ✅ Database Module with @Provides

```kotlin
// In data/local/di/DatabaseModule.kt

@Module
@InstallIn(SingletonComponent::class)
class DatabaseModule {
    @Provides
    @Singleton
    fun provideAppDatabase(@ApplicationContext context: Context): AppDatabase {
        return Room.databaseBuilder(
            context,
            AppDatabase::class.java,
            "blueprint.db",
        ).build()
    }

    @Provides
    fun provideMainScreenDao(database: AppDatabase): MainScreenDao {
        return database.mainScreenDao()
    }
}
```

### ✅ Test Module with @TestInstallIn

```kotlin
// In androidTest/testdi/FakeDataModule.kt

@Module
@TestInstallIn(
    components = [SingletonComponent::class],
    replaces = [DataModule::class],
)
interface FakeDataModule {
    @Binds
    fun bindRepository(fake: FakeMainScreenRepository): MainScreenRepository
}
```

### Hilt Integration Checklist

- [ ] Application class has `@HiltAndroidApp`
- [ ] All ViewModels have `@HiltViewModel`
- [ ] All repository interfaces have implementations
- [ ] All modules use `@Module` + `@InstallIn`
- [ ] Prefer `@Binds` for interfaces (module is `interface`)
- [ ] Use `@Provides` for concrete instances (module is `class`)
- [ ] All singletons marked with `@Singleton`
- [ ] Test modules use `@TestInstallIn`

---

## MVVM & Compose Patterns

### UI State Management

```kotlin
// ✅ Define UI state as sealed interface or data class
sealed interface MainScreenUiState {
    data object Loading : MainScreenUiState
    data class Success(val data: List<String>) : MainScreenUiState
    data class Error(val message: String) : MainScreenUiState
}

// ✅ ViewModel exposes immutable StateFlow
@HiltViewModel
class MainScreenViewModel @Inject constructor(
    private val mainScreenRepository: MainScreenRepository,
) : ViewModel() {
    val uiState: StateFlow<MainScreenUiState> =
        mainScreenRepository.mainScreens
            .map<List<String>, MainScreenUiState> { Success(it) }
            .catch { emit(Error(it.message ?: "Unknown error")) }
            .stateIn(
                viewModelScope,
                SharingStarted.WhileSubscribed(5000),
                Loading,
            )
}
```

### Screen Structure (Two-Composable Pattern)

```kotlin
// ✅ GOOD - Stateful outer, stateless inner

// Stateful: Collects ViewModel state
@Composable
fun MainScreenScreen(
    modifier: Modifier = Modifier,
    viewModel: MainScreenViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    when (uiState) {
        is MainScreenUiState.Loading -> LoadingScreen()
        is MainScreenUiState.Success -> {
            val items = (uiState as MainScreenUiState.Success).data
            MainScreenScreenContent(
                items = items,
                onSave = viewModel::addMainScreen,
                modifier = modifier,
            )
        }
        is MainScreenUiState.Error -> {
            val message = (uiState as MainScreenUiState.Error).message
            ErrorScreen(message)
        }
    }
}

// Stateless: Pure render function
@Composable
internal fun MainScreenScreenContent(
    items: List<String>,
    onSave: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(modifier) {
        // Render UI
    }
}
```

### ViewModel with Event Handler

```kotlin
// ✅ GOOD - Event-driven ViewModel

sealed interface MainScreenEvent {
    data class SaveItem(val name: String) : MainScreenEvent
    data object ClearItems : MainScreenEvent
}

@HiltViewModel
class MainScreenViewModel @Inject constructor(
    private val mainScreenRepository: MainScreenRepository,
) : ViewModel() {
    val uiState: StateFlow<MainScreenUiState> = /* ... */

    fun onEvent(event: MainScreenEvent) {
        when (event) {
            is MainScreenEvent.SaveItem -> addMainScreen(event.name)
            is MainScreenEvent.ClearItems -> clearItems()
        }
    }

    private fun addMainScreen(name: String) {
        viewModelScope.launch {
            mainScreenRepository.add(name)
        }
    }

    private fun clearItems() {
        // Implementation
    }
}
```

### Composable Function Rules

```kotlin
// ✅ GOOD - Pure, no side effects
@Composable
fun MyScreen(modifier: Modifier = Modifier) {
    Column(modifier) {
        Text("Hello")
    }
}

// ✅ GOOD - Side effects in LaunchedEffect
@Composable
fun MyScreen(viewModel: MyViewModel = hiltViewModel()) {
    LaunchedEffect(Unit) {
        viewModel.initialize()
    }
    // Render
}

// ❌ BAD - Direct coroutine in composable
@Composable
fun MyScreen(viewModel: MyViewModel = hiltViewModel()) {
    viewModelScope.launch {  // ❌ WRONG - use LaunchedEffect
        // Code
    }
}

// ❌ BAD - Direct repository access
@Composable
fun MyScreen(repo: Repository = remember { /* ... */ }) {
    // ❌ Screens don't access data layer directly
}
```

---

## Repository & Data Layer

### Flow-Based Reactive Updates

```kotlin
// ✅ Repository always exposes Flow for reactive updates

interface MainScreenRepository {
    // Flow for stream of data
    val mainScreens: Flow<List<String>>

    // Suspend fun for one-off operations
    suspend fun add(name: String)
    suspend fun delete(id: String)
}

// ✅ Implementation uses Room Flow
class DefaultMainScreenRepository @Inject constructor(
    private val mainScreenDao: MainScreenDao,
) : MainScreenRepository {
    override val mainScreens: Flow<List<String>> =
        mainScreenDao.getAllAsFlow()
            .map { entities ->
                entities.map { it.name }
            }

    override suspend fun add(name: String) {
        mainScreenDao.insert(MainScreen(name = name))
    }
}

// ✅ DAO exposes Flow
@Dao
interface MainScreenDao {
    @Query("SELECT * FROM main_screen")
    fun getAllAsFlow(): Flow<List<MainScreen>>

    @Insert
    suspend fun insert(item: MainScreen)
}
```

### Room Entity with Auto-Migrations

```kotlin
// ✅ Entity with version tracking
@Entity(tableName = "main_screen")
data class MainScreen(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val name: String,
    val createdAt: Long = System.currentTimeMillis(),
)

// ✅ Database with version and auto-migrations
@Database(
    entities = [MainScreen::class],
    version = 1,
    autoMigrations = [],  // Add auto-migration specs as needed
    exportSchema = true,
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun mainScreenDao(): MainScreenDao
}
```

---

## Naming Conventions

### Files and Classes

| Type | Pattern | Example |
|------|---------|---------|
| **Screen** | `[Feature]Screen.kt` | `MainScreenScreen.kt` |
| **ViewModel** | `[Feature]ViewModel.kt` | `MainScreenViewModel.kt` |
| **Repository** | `[Feature]Repository.kt` | `MainScreenRepository.kt` |
| **DAO** | `[Feature]Dao.kt` | `MainScreenDao.kt` |
| **Entity** | `[Feature].kt` | `MainScreen.kt` |
| **Module** | `[Layer]Module.kt` | `DataModule.kt`, `DatabaseModule.kt` |
| **Test** | `[Class]Test.kt` | `MainScreenViewModelTest.kt` |

### Variables and Functions

```kotlin
// ✅ Clear, descriptive names

// ViewModels
val mainScreenViewModel: MainScreenViewModel

// UI State
val uiState: StateFlow<MainScreenUiState>

// Repositories
val repository: MainScreenRepository

// Flow/reactive values
val items: Flow<List<String>>

// Event handlers
fun onSaveClick(name: String)
fun onClearItems()

// Composables (PascalCase, verb-based for actions)
@Composable
fun MainScreenScreen(modifier: Modifier = Modifier)

@Composable
fun LoadingScreen()

// Private functions (camelCase)
private fun prepareData()
private suspend fun saveToDatabase()
```

### Package Naming

```kotlin
// Feature package (lowercase, no underscores)
package com.devindie.blueprint.ui.mainscreen

// Data layer (lowercase, by layer)
package com.devindie.blueprint.data
package com.devindie.blueprint.data.di
package com.devindie.blueprint.data.local.database

// Test packages (same as source)
package com.devindie.blueprint.ui.mainscreen  // in androidTest/
package com.devindie.blueprint                // in test/
```

---

## Testing Standards

### Unit Tests (test/)

```kotlin
// ✅ ViewModel tests with Fake repositories

@RunWith(RobolectricTestRunner::class)
class MainScreenViewModelTest {
    private lateinit var viewModel: MainScreenViewModel
    private lateinit var repository: FakeMainScreenRepository

    @Before
    fun setup() {
        repository = FakeMainScreenRepository()
        viewModel = MainScreenViewModel(repository)
    }

    @Test
    fun `uiState initially shows loading`() = runTest {
        // Assert initial state
        assertThat(viewModel.uiState.value).isInstanceOf(Loading::class.java)
    }

    @Test
    fun `uiState shows success when items loaded`() = runTest {
        repository.emit(listOf("Item 1"))
        
        advanceUntilIdle()
        
        val state = viewModel.uiState.value
        assertThat(state).isInstanceOf(Success::class.java)
        assertThat((state as Success).data).containsExactly("Item 1")
    }
}

// ✅ Fake implementations in production package
class FakeMainScreenRepository : MainScreenRepository {
    private val flow = MutableSharedFlow<List<String>>()
    override val mainScreens: Flow<List<String>> = flow.asSharedFlow()

    suspend fun emit(items: List<String>) = flow.emit(items)

    override suspend fun add(name: String) {
        // Fake implementation
    }
}
```

### Architecture Tests (test/)

```kotlin
// ✅ ArchUnit enforces boundaries

@Test
fun `ViewModels should not depend on NavController`() {
    noClasses()
        .that().haveSimpleNameEndingWith("ViewModel")
        .should().dependOnClassesThat().haveNameMatching(".*NavController.*")
        .because("ViewModels must not handle navigation directly")
        .allowEmptyShould(true)
        .check(importedClasses)
}

@Test
fun `Data layer should not depend on UI layer`() {
    noClasses()
        .that().resideInAPackage("..data..")
        .should().dependOnClassesThat().resideInAPackage("..ui..")
        .because("Data layer must not depend on UI layer")
        .allowEmptyShould(true)
        .check(importedClasses)
}
```

### Instrumented Tests (androidTest/)

```kotlin
// ✅ UI tests with Hilt
@RunWith(AndroidJUnit4::class)
@HiltAndroidTest
class MainScreenScreenTest {
    @get:Rule
    val hiltRule = HiltAndroidRule(this)

    @Test
    fun screenDisplaysItems() {
        val testItems = listOf("Item 1", "Item 2")
        // Test implementation
    }
}
```

### Test Minimum Requirements

- [ ] At least one test per ViewModel
- [ ] Cover happy path (success state)
- [ ] Cover error scenarios
- [ ] Cover state transitions
- [ ] All ArchUnit tests pass
- [ ] No hardcoded test data in source code

---

## Development Commands

### Essential Commands

```bash
# ✅ Format code (MUST do before commit)
./gradlew spotlessApply

# ✅ Run all quality checks (same as CI)
./gradlew :app:qualityCheck

# ✅ Run individual checks
./gradlew spotlessCheck          # Formatting
./gradlew detekt                 # Static analysis
./gradlew :app:lint              # Android lint
./gradlew :app:testDebugUnitTest # Unit tests

# ✅ Build
./gradlew assembleDebug
./gradlew build
```

### Pre-Commit Setup

```bash
# Install locally (one-time)
cp pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Now runs automatically on: git commit
```

### Git Workflow

```bash
# Before committing
./gradlew spotlessApply
./gradlew :app:qualityCheck

# If all checks pass
git add .
git commit -m "Clear, descriptive message"

# Pre-commit hook runs automatically
# If it fails, fix violations and commit again

# Push to remote
git push
```

---

## Code Examples

### Complete ViewModel Example

```kotlin
package com.devindie.blueprint.ui.mainscreen

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.devindie.blueprint.data.MainScreenRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed interface MainScreenUiState {
    data object Loading : MainScreenUiState
    data class Success(val data: List<String>) : MainScreenUiState
    data class Error(val message: String) : MainScreenUiState
}

@HiltViewModel
class MainScreenViewModel @Inject constructor(
    private val mainScreenRepository: MainScreenRepository,
) : ViewModel() {
    val uiState: StateFlow<MainScreenUiState> =
        mainScreenRepository.mainScreens
            .map<List<String>, MainScreenUiState>(::Success)
            .catch { emit(Error(it.message ?: "Unknown error")) }
            .stateIn(
                viewModelScope,
                SharingStarted.WhileSubscribed(5000),
                Loading,
            )

    fun addMainScreen(name: String) {
        viewModelScope.launch {
            mainScreenRepository.add(name)
        }
    }
}
```

### Complete Composable Example

```kotlin
package com.devindie.blueprint.ui.mainscreen

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.devindie.blueprint.R

@Composable
fun MainScreenScreen(
    modifier: Modifier = Modifier,
    viewModel: MainScreenViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    when (uiState) {
        is MainScreenUiState.Loading -> LoadingScreen()
        is MainScreenUiState.Success -> {
            val data = (uiState as MainScreenUiState.Success).data
            MainScreenScreenContent(
                items = data,
                onSave = viewModel::addMainScreen,
                modifier = modifier,
            )
        }
        is MainScreenUiState.Error -> {
            val message = (uiState as MainScreenUiState.Error).message
            ErrorScreen(message = message)
        }
    }
}

@Composable
internal fun MainScreenScreenContent(
    items: List<String>,
    onSave: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(modifier) {
        var inputText by remember { mutableStateOf("") }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 24.dp),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            TextField(
                value = inputText,
                onValueChange = { inputText = it },
            )

            Button(
                modifier = Modifier.width(96.dp),
                onClick = { onSave(inputText) },
            ) {
                Text(stringResource(R.string.save_button))
            }
        }

        items.forEach { item ->
            Text(stringResource(R.string.saved_item, item))
        }
    }
}

@Composable
private fun LoadingScreen() {
    Text("Loading...")
}

@Composable
private fun ErrorScreen(message: String) {
    Text("Error: $message")
}
```

### Complete Repository Example

```kotlin
package com.devindie.blueprint.data

import com.devindie.blueprint.data.local.database.MainScreenDao
import com.devindie.blueprint.data.local.database.MainScreen
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

interface MainScreenRepository {
    val mainScreens: Flow<List<String>>
    suspend fun add(name: String)
}

class DefaultMainScreenRepository @Inject constructor(
    private val mainScreenDao: MainScreenDao,
) : MainScreenRepository {
    override val mainScreens: Flow<List<String>> =
        mainScreenDao.getAllAsFlow()
            .map { entities ->
                entities.map { it.name }
            }

    override suspend fun add(name: String) {
        mainScreenDao.insert(MainScreen(name = name))
    }
}
```

### Complete DI Module Example

```kotlin
package com.devindie.blueprint.data.di

import com.devindie.blueprint.data.DefaultMainScreenRepository
import com.devindie.blueprint.data.MainScreenRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
interface DataModule {
    @Singleton
    @Binds
    fun bindsMainScreenRepository(
        impl: DefaultMainScreenRepository,
    ): MainScreenRepository
}
```

---

## Checklist for Code Generation

When generating code, ensure:

### Architecture
- [ ] Follows clean architecture (UI → ViewModel → Repository → Database)
- [ ] ViewModels use `@HiltViewModel` and constructor injection
- [ ] Repositories expose `Flow<T>` for reactive updates
- [ ] No direct data layer access from UI
- [ ] DI modules in `di/` packages with `@Module` + `@InstallIn`

### Code Style
- [ ] No line exceeds 120 characters
- [ ] No wildcard imports
- [ ] 4-space indentation
- [ ] Clear, descriptive naming
- [ ] Trailing commas allowed

### Guardrails
- [ ] ❌ No `!!` (use safe calls, `let`, `require()`)
- [ ] ❌ No `GlobalScope` (use proper scopes)
- [ ] ❌ No `println()` or `printStackTrace()`
- [ ] ❌ No hardcoded strings (use `stringResource()`)
- [ ] ❌ No wildcard imports
- [ ] Max complexity per function: 15
- [ ] Max function length: 60 lines
- [ ] Max class size: 600 lines

### MVVM & Compose
- [ ] Composables are stateless (pass callbacks)
- [ ] ViewModels expose `StateFlow<UiState>`
- [ ] Proper error handling (Loading/Success/Error states)
- [ ] Side effects in `LaunchedEffect`, not in composable body
- [ ] Use `hiltViewModel()` to obtain ViewModels
- [ ] Collect state with `collectAsStateWithLifecycle()`

### Testing
- [ ] ViewModel has corresponding test class
- [ ] At least success path, error path, state transition tests
- [ ] Architecture tests pass (ArchUnit)
- [ ] No hardcoded test data in production code

### Before Commit
- [ ] `./gradlew spotlessApply` run
- [ ] `./gradlew :app:qualityCheck` passes
- [ ] Pre-commit hook passes
- [ ] All new code has tests
- [ ] Commit message is clear and descriptive

---

## Configuration Reference

### Spotless Configuration
- **File:** `app/build.gradle.kts`
- **Rules:** Max line 120, no wildcards, function-naming disabled (Composables), trailing commas allowed
- **Command:** `./gradlew spotlessCheck` or `spotlessApply`

### Detekt Configuration
- **File:** `detekt.yml`
- **Key Rules:** No `!!`, no `GlobalScope`, no println, max complexity 15, max lines 60
- **Command:** `./gradlew detekt`

### Android Lint Configuration
- **File:** `app/lint.xml`
- **Key Rules:** Hardcoded text errors, unused resources errors
- **Command:** `./gradlew :app:lint`

### ArchUnit Configuration
- **File:** `app/src/test/java/com/devindie/blueprint/ArchitectureTest.kt`
- **Key Rules:** ViewModels can't use NavController, data can't depend on UI
- **Command:** `./gradlew :app:testDebugUnitTest`

### Editor Configuration
- **File:** `.editorconfig`
- **Rules:** 4-space indent, UTF-8, LF line endings, trim trailing whitespace

---

## Maintenance & Updates

**When to update this guide:**
- New project standards established
- New tools added to enforcement pipeline
- Architecture patterns change
- Testing requirements updated
- Command shortcuts added/removed

**How to update:**
1. Make changes to configuration files
2. Update corresponding section in this guide
3. Commit with message: "docs: update AI code generation guide"
4. Communicate changes to team

---

## Quick Reference Links

- **GitHub Repository:** https://github.com/khoa-nguyen-bk18/blueprint-android
- **CI/CD Pipeline:** `.github/workflows/ci.yml`
- **Project Operating Manual:** `documentation/ai/project_operating_manual.md`
- **Enforcement Rules:** `documentation/ai/enforce_rule.md`
- **Implementation Details:** `GUARDRAILS_IMPLEMENTATION.md`

---

**Last Updated:** January 17, 2026  
**Maintained By:** Development Team  
**Status:** Production Ready - Zero Violations
