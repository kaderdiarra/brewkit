#!/usr/bin/env bash
# Detection functions for installed tools

# ── Cache variables ──
# Populated by cache_brew_lists / cache_vscode_extensions for bulk lookups
_BREW_FORMULA_CACHE=""
_BREW_CASK_CACHE=""
_VSCODE_EXT_CACHE=""
_BREW_CACHED=false
_VSCODE_CACHED=false

# ── Cache population ──

cache_brew_lists() {
  if [[ "$_BREW_CACHED" == "true" ]]; then return; fi
  if is_brew_installed; then
    _BREW_FORMULA_CACHE=$(brew list --formula 2>/dev/null)
    _BREW_CASK_CACHE=$(brew list --cask 2>/dev/null)
  fi
  _BREW_CACHED=true
}

cache_vscode_extensions() {
  if [[ "$_VSCODE_CACHED" == "true" ]]; then return; fi
  if is_vscode_installed; then
    _VSCODE_EXT_CACHE=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')
  fi
  _VSCODE_CACHED=true
}

# ── Basic checks ──

is_brew_installed() {
  command -v brew &>/dev/null
}

is_gum_installed() {
  command -v gum &>/dev/null
}

is_fzf_installed() {
  command -v fzf &>/dev/null
}

is_xcode_cli_installed() {
  xcode-select -p &>/dev/null
}

is_command_installed() {
  command -v "$1" &>/dev/null
}

is_app_installed() {
  local app_path="$1"
  [[ -d "$app_path" ]]
}

is_brew_formula_installed() {
  local formula="$1"
  if [[ "$_BREW_CACHED" == "true" ]]; then
    echo "$_BREW_FORMULA_CACHE" | grep -q "^${formula}$"
  else
    brew list --formula 2>/dev/null | grep -q "^${formula}$"
  fi
}

is_brew_cask_installed() {
  local cask="$1"
  if [[ "$_BREW_CACHED" == "true" ]]; then
    echo "$_BREW_CASK_CACHE" | grep -q "^${cask}$"
  else
    brew list --cask 2>/dev/null | grep -q "^${cask}$"
  fi
}

is_vscode_installed() {
  command -v code &>/dev/null || [[ -d "/Applications/Visual Studio Code.app" ]]
}

is_vscode_extension_installed() {
  local ext_id="$1"
  if [[ "$_VSCODE_CACHED" == "true" ]]; then
    local ext_id_lower
    ext_id_lower=$(echo "$ext_id" | tr '[:upper:]' '[:lower:]')
    echo "$_VSCODE_EXT_CACHE" | grep -q "^${ext_id_lower}$"
  else
    code --list-extensions 2>/dev/null | grep -qi "^${ext_id}$"
  fi
}

is_oh_my_zsh_installed() {
  [[ -d "$HOME/.oh-my-zsh" ]]
}

is_nvm_installed() {
  [[ -d "$HOME/.nvm" ]]
}

has_brew_upgrade() {
  local formula="$1"
  brew outdated 2>/dev/null | grep -q "^${formula}"
}

# Get install status label for display
get_status_label() {
  local _key="$1"  # reserved for future use
  local check_type="$2"
  local check_value="$3"

  case "$check_type" in
    app)
      if is_app_installed "$check_value"; then
        echo "installed"
      else
        echo "not_installed"
      fi
      ;;
    cask)
      if is_brew_cask_installed "$check_value"; then
        echo "installed"
      else
        echo "not_installed"
      fi
      ;;
    formula)
      if is_brew_formula_installed "$check_value"; then
        echo "installed"
      else
        echo "not_installed"
      fi
      ;;
    command)
      if is_command_installed "$check_value"; then
        echo "installed"
      else
        echo "not_installed"
      fi
      ;;
    vscode_ext)
      if is_vscode_extension_installed "$check_value"; then
        echo "installed"
      else
        echo "not_installed"
      fi
      ;;
    directory)
      if [[ -d "$check_value" ]]; then
        echo "installed"
      else
        echo "not_installed"
      fi
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

# Verify a tool was installed correctly after brew install
verify_install() {
  local name="$1"
  local check_type="$2"
  local check_value="$3"

  local status
  status=$(get_status_label "" "$check_type" "$check_value")
  if [[ "$status" == "installed" ]]; then
    return 0
  else
    log "VERIFY FAILED: $name ($check_type:$check_value)"
    return 1
  fi
}
