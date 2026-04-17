#!/usr/bin/env bash
# Misc utilities

get_arch() {
  uname -m
}

get_macos_version() {
  sw_vers -productVersion
}

backup_file() {
  local file="$1"
  local backup_dir="$HOME/.config/brewkit/backups"
  mkdir -p "$backup_dir"
  if [[ -f "$file" ]]; then
    local basename
    basename=$(basename "$file")
    cp "$file" "${backup_dir}/${basename}.backup.$(date +%Y%m%d%H%M%S)"
    log "Backed up $file"
  fi
}

# Add content between markers in a file (idempotent)
add_to_file_between_markers() {
  local file="$1"
  local content="$2"
  local marker_start="# >>> brewkit >>>"
  local marker_end="# <<< brewkit <<<"

  if [[ ! -f "$file" ]]; then
    touch "$file"
  fi

  # Remove existing block if present
  if grep -q "$marker_start" "$file" 2>/dev/null; then
    sed -i '' "/$marker_start/,/$marker_end/d" "$file"
  fi

  # Append new block
  {
    echo ""
    echo "$marker_start"
    echo "$content"
    echo "$marker_end"
  } >> "$file"
}

# Count items in a newline-separated string
count_items() {
  echo "$1" | grep -c '[^[:space:]]' 2>/dev/null || echo 0
}

# Export current selections to a file for replay
export_selections() {
  local file="$1"
  {
    echo "# Brewkit — saved selections"
    echo "# Generated: $(date)"
    echo "# Re-import with: make install-from FILE=path/to/this/file"
    echo ""
    echo "BUNDLE=custom"
    echo ""

    if [[ ${#SELECTED_APPS[@]} -gt 0 ]]; then
      echo "APPS=("
      for entry in "${SELECTED_APPS[@]}"; do
        echo "  \"$(get_field "$entry" 1)\""
      done
      echo ")"
    fi

    if [[ ${#SELECTED_DEVTOOLS[@]} -gt 0 ]]; then
      echo "DEVTOOLS=("
      for entry in "${SELECTED_DEVTOOLS[@]}"; do
        echo "  \"$(get_field "$entry" 1)\""
      done
      echo ")"
    fi

    if [[ ${#SELECTED_EXTENSIONS[@]} -gt 0 ]]; then
      echo "EXTENSIONS=("
      for entry in "${SELECTED_EXTENSIONS[@]}"; do
        echo "  \"$(get_field "$entry" 1)\""
      done
      echo ")"
    fi

    if [[ ${#SELECTED_SYSTEM[@]} -gt 0 ]]; then
      echo "SYSTEM=("
      for entry in "${SELECTED_SYSTEM[@]}"; do
        echo "  \"$(get_field "$entry" 1)\""
      done
      echo ")"
    fi

    if [[ ${#SELECTED_SHELL_OPTIONS[@]} -gt 0 ]]; then
      echo "SHELL_OPTIONS=(${SELECTED_SHELL_OPTIONS[*]})"
    fi

    echo "CONFIGURE_GIT=$CONFIGURE_GIT"
    echo "CONFIGURE_SSH=$CONFIGURE_SSH"
    echo "CONFIGURE_VSCODE_SETTINGS=$CONFIGURE_VSCODE_SETTINGS"
    echo "CONFIGURE_DEFAULT_BROWSER=$CONFIGURE_DEFAULT_BROWSER"
    echo "DEFAULT_BROWSER=$DEFAULT_BROWSER"
    echo "INSTALL_NODE=$INSTALL_NODE"
    echo "INSTALL_NPM_GLOBALS=$INSTALL_NPM_GLOBALS"
  } > "$file"
}
