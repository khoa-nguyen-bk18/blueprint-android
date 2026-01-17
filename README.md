# BluePrint Android

Clean Architecture Android template with Jetpack Compose, Hilt DI, Room database, and **comprehensive quality guardrails** enforcing zero violations.

[![Android CI](https://github.com/khoa-nguyen-bk18/blueprint-android/actions/workflows/ci.yml/badge.svg)](https://github.com/khoa-nguyen-bk18/blueprint-android/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

---

## 🎯 Features

### Architecture
- **Clean Architecture** with clear separation of concerns
- **MVVM Pattern** with Jetpack Compose
- **Unidirectional Data Flow** (UI → ViewModel → Repository)
- **Reactive Programming** with Kotlin Flow
- **Dependency Injection** via Hilt (Dagger)
- **Room Database** with auto-migrations

### Quality Guardrails (Zero Tolerance)
- ✅ **Spotless + ktlint** - Automatic code formatting
- ✅ **Detekt** - Static analysis (no `!!`, `GlobalScope`, `println`)
- ✅ **Android Lint** - Strict error enforcement
- ✅ **ArchUnit** - Architecture boundary tests
- ✅ **Pre-commit Hooks** - Local violation prevention
- ✅ **CI/CD Pipeline** - Mandatory quality gate

**Status:** 🎉 **Production ready with ZERO violations**

---

## 🚀 Quick Start

### 1. Clone and Build
```bash
git clone https://github.com/khoa-nguyen-bk18/blueprint-android.git
cd blueprint-android
./gradlew build
```

### 2. Install Pre-Commit Hook
```bash
cp pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### 3. Run Quality Checks
```bash
# Run all checks (same as CI)
./gradlew :app:qualityCheck

# Auto-fix formatting
./gradlew spotlessApply
```

---

## 📦 Tech Stack

| Component | Technology | Version |
|-----------|------------|---------|
| **Language** | Kotlin | 2.2.21 |
| **UI Framework** | Jetpack Compose | 2025.11.01 BOM |
| **DI** | Hilt (Dagger) | 2.57.2 |
| **Database** | Room | 2.8.4 |
| **Navigation** | Navigation Compose | 2.9.6 |
| **Build** | Gradle | 9.2.1 |
| **Min SDK** | 23 | - |
| **Target SDK** | 36 | - |

---

## 🏗️ Project Structure

```
app/src/main/java/com/devindie/blueprint/
├── BluePrint.kt                    # @HiltAndroidApp
├── data/                           # Data Layer
│   ├── MainScreenRepository.kt     # Repository interface + impl
│   ├── di/                         # Hilt data modules
│   └── local/
│       ├── database/               # Room entities + DAOs
│       └── di/                     # Database module
└── ui/                             # UI Layer
    ├── MainActivity.kt             # Entry point
    ├── Navigation.kt               # Nav graph
    ├── mainscreen/                 # Feature package
    │   ├── MainScreenScreen.kt     # Composable
    │   └── MainScreenViewModel.kt  # @HiltViewModel
    └── theme/                      # Material Theme
```

---

## 🛡️ Quality Enforcement

### Unified Command
```bash
./gradlew :app:qualityCheck
```
Runs (in order):
1. **Spotless** - Code formatting
2. **Detekt** - Static analysis
3. **Android Lint** - Android-specific checks
4. **Unit Tests** - Including ArchUnit architecture tests

### Pre-Commit Hook
Automatically checks on every commit:
- ❌ No `!!` (non-null assertions)
- ❌ No `GlobalScope` usage
- ❌ No `println()` or `printStackTrace()`
- ⚠️ Warning for hardcoded strings
- ✅ Spotless formatting

### CI Pipeline
GitHub Actions runs on every push/PR:
- Must pass all quality checks
- Blocks merge on failure
- Uploads reports as artifacts

---

## 📋 Enforced Rules

### From POM (Project Operating Manual)

| Rule | Enforcement |
|------|-------------|
| No `!!` anywhere | Detekt + Pre-commit |
| No `GlobalScope` | Detekt + Pre-commit |
| No `println`/`printStackTrace` | Detekt + Pre-commit |
| Max line length 120 | Spotless |
| Max complexity 15 | Detekt |
| No wildcard imports | Spotless + Detekt |
| Hardcoded strings = error | Android Lint |
| ViewModels use `@HiltViewModel` | ArchUnit |
| ViewModels can't use NavController | ArchUnit |
| Data layer can't depend on UI | ArchUnit |

**Total:** 15+ automated rules enforced at build time

---

## 📚 Documentation

- **[Enforcement Rules](documentation/ai/enforce_rule.md)** - Complete guide to all quality rules
- **[Project Operating Manual](documentation/ai/project_operating_manual.md)** - Architecture guidelines & patterns
- **[Implementation Summary](GUARDRAILS_IMPLEMENTATION.md)** - What was implemented and how

---

## 🔧 Development Workflow

### Before Committing
```bash
# 1. Format your code
./gradlew spotlessApply

# 2. Run quality checks
./gradlew :app:qualityCheck

# 3. Commit (pre-commit hook runs automatically)
git commit -m "Your message"
```

### Adding New Features
1. Create feature package in `ui/<feature>/`
2. Create ViewModel with `@HiltViewModel`
3. Create Composable screen
4. Add repository in `data/`
5. Update DI modules in `di/`
6. Run `./gradlew :app:qualityCheck`

---

## 🧪 Testing

```bash
# Unit tests (including ArchUnit)
./gradlew :app:testDebugUnitTest

# Instrumented tests
./gradlew :app:connectedAndroidTest

# Architecture tests only
./gradlew :app:testDebugUnitTest --tests "*ArchitectureTest"
```

---

## 🎓 Learning Resources

This template demonstrates:
- ✅ Clean Architecture principles
- ✅ MVVM with Jetpack Compose
- ✅ Hilt dependency injection
- ✅ Room database with Flow
- ✅ Navigation Compose
- ✅ Automated quality enforcement
- ✅ CI/CD best practices

Perfect for:
- Starting new Android projects
- Learning modern Android development
- Enforcing team coding standards
- Interview/portfolio projects

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Run quality checks (`./gradlew :app:qualityCheck`)
4. Commit changes (`git commit -m 'Add amazing feature'`)
5. Push to branch (`git push origin feature/amazing-feature`)
6. Open Pull Request

**Note:** All PRs must pass CI quality checks.

---

## 📄 License

```
Copyright (C) 2022 The Android Open Source Project

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

---

## 🌟 Show Your Support

If this template helped you, give it a ⭐️!

---

## 📞 Contact

**Maintainer:** khoa-nguyen-bk18  
**Repository:** [blueprint-android](https://github.com/khoa-nguyen-bk18/blueprint-android)

---

**Built with ❤️ and enforced with 🛡️**
