#!/usr/bin/env bash
set -euo pipefail

./tools/check-fast.sh

# Heavier checks (optional; enable if you have emulator in CI)
# ./gradlew --no-daemon connectedDebugAndroidTest

# Build verification
./gradlew --no-daemon assembleDebug

echo "✅ check passed"
