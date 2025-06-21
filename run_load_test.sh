#!/bin/bash

set -e

REPORT_DIR="stress_test/reports"
CONFIG_DIR="stress_test"

VALID_PROFILES=("fastapi-sync" "fastapi-async" "express")
VALID_TESTS=("write-heavy")

run_test() {
  PROFILE=$1
  TEST_TYPE=$2
  echo "=============================="
  echo ">>> Starting $TEST_TYPE test for: $PROFILE"
  echo "=============================="

  echo ">>> Starting services..."
  docker compose --profile "$PROFILE" up -d --build

  echo ">>> Waiting 10 seconds for services to warm up..."
  sleep 10

  REPORT_JSON="$REPORT_DIR/${PROFILE}-${TEST_TYPE}.json"
  REPORT_HTML="$REPORT_DIR/${PROFILE}-${TEST_TYPE}-report.html"
  CONFIG_FILE="$CONFIG_DIR/${TEST_TYPE}-test.yml"

  echo ">>> Running Artillery test..."
  artillery run -e "$PROFILE" "$CONFIG_FILE" -o "$REPORT_JSON"

  echo ">>> Generating HTML report..."
  artillery report "$REPORT_JSON" --output "$REPORT_HTML"

  echo ">>> Stopping and removing containers..."
  docker compose --profile "$PROFILE" down -v

  echo "✅ Completed $TEST_TYPE test for $PROFILE"
  echo "📄 Report saved to $REPORT_HTML"
  echo ""
}

# Ensure reports directory exists
mkdir -p "$REPORT_DIR"

# If no arguments are given, then exit
if [[ -z "$1" ]] || [[ -z "$2" ]]; then
  echo "Usage: ./run_load_test.sh <profile> <test-type>"
  echo "Profiles: ${VALID_PROFILES[*]}"
  echo "Test types: ${VALID_TESTS[*]}"
  exit 1
fi

# Validate profile
if [[ ! " ${VALID_PROFILES[*]} " =~ " $1 " ]]; then
  echo "❌ Invalid profile: '$1'"
  echo "Valid profiles: ${VALID_PROFILES[*]}"
  exit 1
fi

# Validate test type
if [[ ! " ${VALID_TESTS[*]} " =~ " $2 " ]]; then
  echo "❌ Invalid test type: '$2'"
  echo "Valid test types: ${VALID_TESTS[*]}"
  exit 1
fi

# Run test
run_test "$1" "$2"
