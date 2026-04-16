#!/usr/bin/env bash
# Detection functions for installed tools

is_brew_installed() {
  command -v brew &>/dev/null
}

is_gum_installed() {
  command -v gum &>/dev/null
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
  brew list --formula 2>/dev/null | grep -q "^${formula}$"
}

is_brew_cask_installed() {
  local cask="$1"
  brew list --cask 2>/dev/null | grep -q "^${cask}$"
}

is_vscode_installed() {
  command -v code &>/dev/null || [[ -d "/Applications/Visual Studio Code.app" ]]
}

is_vscode_extension_installed() {
  local ext_id="$1"
  code --list-extensions 2>/dev/null | grep -qi "^${ext_id}$"
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
