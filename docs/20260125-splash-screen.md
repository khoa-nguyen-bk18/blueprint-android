# Feature Spec — splash screen

- Date: 2026-01-25
- Version: 0.1
- Priority: P0 (must)
- Status: Draft

---

## A) Overview
- One-line summary: show an splash screen with an centered icon right when opening the app
- Goal (user outcome): user can see the splash screen look like the app icon, improve the user exp as well as ui
- Business value: create an smooth experience when starting an app

### Non-goals (NOT in this version)
- TBD

---

## B) Users & permissions
### Primary user(s)
- all users

### Secondary user(s)
- all

### Permission rules (who can view/do this)
all users, no require permissions

### Preconditions
none

---

## C) UX/UI behavior (behavioral, not pixel-perfect)

### Screens involved
- if user is logged in, go to home screen, else goes to Login screen

### Entry points
- app icon on launcher

### Exit points
- On success, go to: HomeScreen or LoginScreeb
- On cancel/back, do: none
- If user leaves mid-way: none

### Inputs
- TBD


### Actions
- Primary CTA: TBD
- Primary CTA enabled when: TBD
- Prevent double submit?: TBD
- Secondary actions: TBD

### Feedback placement
- Loading indicator location: TBD
- Error display style: inline
- Success feedback: TBD

### Empty states (if applicable)
- TBD

---

## D) State model (must be deterministic)
- TBD


---

## E) Functional requirements (SHALL)
- open the LoginScreen or HomeScreen when auto close the SplashScreen

---

## F) Business rules (decision logic + examples)

### Validation rules
- TBD

### Decision rules (if/then)
- TBD

### Ordering / dedup / idempotency rules
- TBD

---

## G) Data (business view)

### Data inputs used (from user/system)
- non

### Data outputs shown to user
- none

### What must be saved (and when)
- none

### What must NOT be saved/logged (PII/security)
- none

### Retention (if relevant)
none

---

## H) Error scenarios & recovery
- none

---

## I) Acceptance criteria (Given/When/Then)
- User must see the splash screen right away whenopening tha app

---

## J) Android/Kotlin notes (optional but recommended)
none

---

## K) Tracking / audit (optional)
- Track events?: no

### Events list
- TBD

---

## L) Open questions
- none
