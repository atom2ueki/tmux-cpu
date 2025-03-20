#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get GPU percentage
gpu_percentage=$("$CURRENT_DIR"/gpu_percentage.sh)

# Get raw percentage for load bar calculations
gpu_percentage_raw=$("$CURRENT_DIR"/gpu_percentage.sh raw)

# Strip any newlines
gpu_percentage=$(echo -n "$gpu_percentage" | tr -d '\n')
gpu_percentage_raw=$(echo -n "$gpu_percentage_raw" | tr -d '\n')

# Check if we have a GPU or got a valid GPU percentage
if [[ "$gpu_percentage" == "No GPU" || -z "$gpu_percentage" ]]; then
  echo "[No GPU]"
  exit 0
fi

# Use the shared load bar component
"$CURRENT_DIR"/load_bar.sh "gpu" "$gpu_percentage_raw"
