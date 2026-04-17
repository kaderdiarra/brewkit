#!/usr/bin/env bash
# Preview helper for fzf — extracts tool name from selection line and shows details
# Called by fzf's --preview flag with the current line as $1

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

line="$1"

# Strip ANSI escape codes
# shellcheck disable=SC2001
line=$(echo "$line" | sed $'s/\033\\[[0-9;]*m//g')

# Skip category headers and empty lines
[[ -z "$line" ]] && exit 0
[[ "$line" == ──* ]] && exit 0

# Extract name: strip [x] prefix and — description suffix
name=$(echo "$line" | sed 's/\[.\] *//' | sed 's/ *—.*//' | xargs)

[[ -z "$name" ]] && exit 0

exec bash "${SCRIPT_DIR}/info.sh" "$name"
