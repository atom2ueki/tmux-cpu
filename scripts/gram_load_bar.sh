#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get total GRAM information
total_gram=$("$CURRENT_DIR"/gram_usage.sh total)

# Get GRAM percentage
gram_percentage=$("$CURRENT_DIR"/gram_percentage.sh)

# Get raw percentage for load bar calculations
gram_percentage_raw=$("$CURRENT_DIR"/gram_percentage.sh raw)

# Strip any newlines
gram_percentage=$(echo -n "$gram_percentage" | tr -d '\n')
gram_percentage_raw=$(echo -n "$gram_percentage_raw" | tr -d '\n')
total_gram=$(echo -n "$total_gram" | tr -d '\n')

# Check if we have a GPU or got a valid GRAM percentage
if [[ "$gram_percentage" == "No GPU" || -z "$gram_percentage" ]]; then
  echo "[No GPU]"
  exit 0
fi

# Get GRAM usage
gram_usage=$("$CURRENT_DIR"/gram_usage.sh)
gram_usage=$(echo -n "$gram_usage" | tr -d '\n')

# Use the shared load bar component
"$CURRENT_DIR"/load_bar.sh "gram" "$gram_percentage_raw" "$total_gram/$gram_usage"
