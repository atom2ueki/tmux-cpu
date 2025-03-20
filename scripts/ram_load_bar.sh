#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

# Get total RAM information
total_ram=$("$CURRENT_DIR"/ram_usage.sh total)

# Get RAM percentage
ram_percentage=$("$CURRENT_DIR"/ram_percentage.sh)

# Get raw percentage for load bar calculations
ram_percentage_raw=$("$CURRENT_DIR"/ram_percentage.sh raw)

# Strip any newlines
ram_percentage=$(echo -n "$ram_percentage" | tr -d '\n')
ram_percentage_raw=$(echo -n "$ram_percentage_raw" | tr -d '\n')
total_ram=$(echo -n "$total_ram" | tr -d '\n')

# Check if we got a valid RAM percentage
if [[ -z "$ram_percentage" || "$ram_percentage" == "0.0%" ]]; then
  echo "[--]"
  exit 0
fi

# Get RAM usage
ram_usage=$("$CURRENT_DIR"/ram_usage.sh)
ram_usage=$(echo -n "$ram_usage" | tr -d '\n')

# Use the shared load bar component
"$CURRENT_DIR"/load_bar.sh "ram" "$ram_percentage_raw" "$total_ram/$ram_usage"
