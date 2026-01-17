# BluePrint Android - Code Quality Enforcement Rules

## Overview
This document describes the automated guardrails enforced in the BluePrint Android project to maintain code quality, architectural boundaries, and team standards.

## Enforcement Layers

### 1. Pre-Commit Hooks (Developer Local)
Runs immediately before `git commit` to catch violations early.

**Location:** `.git/hooks/pre-commit` (install from `pre-commit` script)

**Checks:**
- ❌ No `!!` (non-null assertions)
- ❌ No `GlobalScope` usage
- ❌ No `println()` or `printStackTrace()`
- ⚠️ Warning for hardcoded strings in `Text()` composables
- ✅ Spotless formatting check

**Installation:**
```bash
cp pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

---

### 2. Spotless + ktlint (Code Formatting)
Enforces consistent Kotlin code style across the project.

**Command:** `./gradlew spotlessCheck` or `./gradlew spotlessApply`

**Rules:**
- No wildcard imports
- Max line length: 120 characters
- Consistent indentation and spacing
- Trailing commas allowed (Kotlin style)
- Function naming: disabled (allows Composable functions)

**Configuration:** 
- [app/build.gradle.kts](app/build.gradle.kts) - Spotless block
- [.editorconfig](.editorconfig) - IDE formatting rules

---

### 3. Detekt (Static Analysis)
Catches code smells, complexity issues, and POM violations.

**Command:** `./gradlew detekt`

**Key Rules:**
- ❌ No `!!` (UnsafeCallOnNullableType)
- ❌ No `GlobalScope` (GlobalCoroutineUsage)
- ❌ No `println`/`printStackTrace` (ForbiddenMethodCall)
- ❌ Max cyclomatic complexity: 15 per function
- ❌ Max function length: 60 lines
- ❌ Max class size: 600 lines
- ❌ Wildcard imports forbidden

**Configuration:** [detekt.yml](detekt.yml)

**Exceptions:**
- `@Composable` functions exempt from naming rules
- `@Preview` functions exempt from unused warnings

---

### 4. Android Lint (Android-Specific Checks)
Enforces Android best practices and catches resource/security issues.

**Command:** `./gradlew :app:lint`

**Error Severity (Build Fails):**
- Hardcoded text (outside tests)
- Unused resources
- Missing permissions
- Security issues (world-readable files, JavaScript enabled, etc.)
- Recycle violations

**Configuration:** [app/lint.xml](app/lint.xml)

**Options:**
- `abortOnError = true` - Fail builds on errors
- `baseline = null` - No baseline allowed (clean slate enforcement)
- `checkDependencies = true` - Check library code too

---

### 5. ArchUnit (Architecture Boundaries)
Enforces POM architecture rules at test time.

**Command:** `./gradlew :app:testDebugUnitTest --tests "*ArchitectureTest"`

**Rules:**
1. **ViewModels must not depend on NavController**
   - Navigation handled via callbacks/UiEffects
   
2. **ViewModels must be annotated with @HiltViewModel**
   - All DI through Hilt, no manual factories
   
3. **Data layer must not depend on UI layer**
   - Unidirectional dependency flow
   
4. **DI modules must be properly annotated**
   - All modules use `@Module` annotation

**Test File:** [app/src/test/java/com/devindie/blueprint/ArchitectureTest.kt](app/src/test/java/com/devindie/blueprint/ArchitectureTest.kt)

---

### 6. CI Pipeline (GitHub Actions)
Automated checks on every push/PR to prevent violations from merging.

**Location:** `.github/workflows/ci.yml`

**Pipeline Stages:**
1. **Checkout & Setup** - Java 17, Gradle cache
2. **Format Check** - `spotlessCheck`
3. **Static Analysis** - `detekt`
4. **Lint** - `:app:lint`
5. **Unit Tests** - `testDebugUnitTest` (includes ArchUnit)
6. **Build** - `assembleDebug`
7. **Reports** - Upload test results and lint reports

**Required:** All checks must pass before merge.

---

## Quick Reference: Commands

### Developer Workflow
```bash
# Before committing - auto-format code
./gradlew spotlessApply

# Run all quality checks locally (same as CI)
./gradlew qualityCheck

# Fix specific issues
./gradlew spotlessApply          # Format code
./gradlew detekt                 # Static analysis
./gradlew :app:lint              # Android lint
./gradlew testDebugUnitTest      # Unit + ArchUnit tests
```

### CI Command (Single Gate)
```bash
./gradlew qualityCheck
```

This runs all checks in sequence:
- spotlessCheck
- detekt
- lint
- testDebugUnitTest

---

## POM-Specific Rules Enforced

### From Project Operating Manual

1. ✅ **No `!!` anywhere** - Enforced by Detekt + pre-commit
2. ✅ **No `GlobalScope`** - Enforced by Detekt + pre-commit
3. ✅ **No hardcoded strings** - Enforced by Lint + pre-commit warning
4. ✅ **DI via Hilt only** - Enforced by ArchUnit
5. ✅ **No business logic in Composables** - Manually reviewed (hard to automate)
6. ✅ **Screens never call data/ directly** - Enforced by ArchUnit
7. ✅ **ViewModels don't use NavController** - Enforced by ArchUnit
8. ✅ **Consistent formatting** - Enforced by Spotless
9. ✅ **No blocking work on Main** - Partially by Detekt warnings
10. ✅ **Architecture boundaries respected** - Enforced by ArchUnit

---

## Bypassing Checks (Emergency Only)

### Skip pre-commit hook (NOT RECOMMENDED)
```bash
git commit --no-verify -m "Emergency fix"
```

### Skip specific Detekt rules
Add to file:
```kotlin
@Suppress("RuleName")
```

### Skip CI (NOT ALLOWED)
CI checks are mandatory and cannot be skipped.

---

## Adding New Rules

### 1. Add to Detekt
Edit [detekt.yml](detekt.yml) and add rule configuration.

### 2. Add to ArchUnit
Add test method to [ArchitectureTest.kt](app/src/test/java/com/devindie/blueprint/ArchitectureTest.kt).

### 3. Add to Pre-Commit
Edit [pre-commit](pre-commit) script and add grep check.

### 4. Update this Document
Document the new rule in this file.

---

## Troubleshooting

**Q: Spotless fails with "Unexpected formatting"**
A: Run `./gradlew spotlessApply` to auto-fix.

**Q: Detekt fails with deprecated rule error**
A: Check [detekt.yml](detekt.yml) for outdated configuration.

**Q: ArchUnit test fails**
A: Review the test output - it shows exact violations with file locations.

**Q: Pre-commit hook not running**
A: Ensure it's executable: `chmod +x .git/hooks/pre-commit`

---

## References

- **Spotless:** https://github.com/diffplug/spotless
- **Detekt:** https://detekt.dev/
- **ArchUnit:** https://www.archunit.org/
- **ktlint:** https://pinterest.github.io/ktlint/
