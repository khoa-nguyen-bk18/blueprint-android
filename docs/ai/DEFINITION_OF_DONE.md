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
