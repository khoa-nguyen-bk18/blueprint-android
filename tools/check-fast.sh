#!/usr/bin/env bash
set -euo pipefail

# Enforce scope control
./tools/ai-allowlist-check.sh

# Android recommended fast checks (adjust tasks to your repo)
# - spotlessCheck (format/lint)
# - detekt (static analysis)
# - lintDebug (Android Lint)
# - testDebugUnitTest (unit tests)
./gradlew --no-daemon \
  spotlessCheck \
  detekt \
  lintDebug \
  testDebugUnitTest

echo "✅ check-fast passed"
