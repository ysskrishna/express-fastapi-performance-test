#!/bin/bash

set -e

REPORT_DIR="stress_test/reports"
CONFIG_FILE="stress_test/load-test.yml"

VALID_PROFILES=("fastapi-sync" "fastapi-async" "express")

run_test() {
  PROFILE=$1
  echo "=============================="
  echo ">>> Starting test for: $PROFILE"
  echo "=============================="

  echo ">>> Starting services..."
  docker compose --profile "$PROFILE" up -d --build

  echo ">>> Waiting 10 seconds for services to warm up..."
  sleep 10

  REPORT_JSON="$REPORT_DIR/${PROFILE}.json"
  REPORT_HTML="$REPORT_DIR/${PROFILE}-report.html"

  echo ">>> Running Artillery test..."
  artillery run -e "$PROFILE" "$CONFIG_FILE" -o "$REPORT_JSON"

  echo ">>> Generating HTML report..."
  artillery report "$REPORT_JSON" --output "$REPORT_HTML"

  echo ">>> Stopping and removing containers..."
  docker compose --profile "$PROFILE" down -v

  echo "✅ Completed test for $PROFILE"
  echo "📄 Report saved to $REPORT_HTML"
  echo ""
}

# Ensure reports directory exists
mkdir -p "$REPORT_DIR"

# If no argument is given, then exit
if [[ -z "$1" ]]; then
  echo "Usage: ./run_load_test.sh <fastapi-sync | fastapi-async | express>"
  exit 1
fi


# Validate input
if [[ ! " ${VALID_PROFILES[*]} " =~ " $1 " ]]; then
  echo "❌ Invalid profile: '$1'"
  echo "Usage: ./run_load_test.sh <fastapi-sync | fastapi-async | express>"
  echo "Or run without arguments to test all."
  exit 1
fi

# Run single test
run_test "$1"
