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
