#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

# Get CPU percentage
cpu_percentage=$("$CURRENT_DIR"/cpu_percentage.sh)

# Get raw percentage for load bar calculations
cpu_percentage_raw=$("$CURRENT_DIR"/cpu_percentage.sh raw)

# Strip any newlines
cpu_percentage=$(echo -n "$cpu_percentage" | tr -d '\n')
cpu_percentage_raw=$(echo -n "$cpu_percentage_raw" | tr -d '\n')

# Check if we got a valid CPU percentage
if [[ -z "$cpu_percentage" || "$cpu_percentage" == "No CPU" ]]; then
  echo "[--]"
  exit 0
fi

# Use the shared load bar component
"$CURRENT_DIR"/load_bar.sh "cpu" "$cpu_percentage_raw"
