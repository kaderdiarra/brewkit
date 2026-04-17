#!/usr/bin/env bash
# Phase 2-3: Bundle and item selection

SELECTED_APPS=()
SELECTED_DEVTOOLS=()
SELECTED_EXTENSIONS=()
SELECTED_SYSTEM=()
SELECTED_SHELL_OPTIONS=()
INSTALL_NODE=false
INSTALL_NPM_GLOBALS=false
CONFIGURE_GIT=false
CONFIGURE_SSH=false
CONFIGURE_VSCODE_SETTINGS=false
CONFIGURE_DEFAULT_BROWSER=false
DEFAULT_BROWSER=""

run_phase_select() {
  print_step "2" "6" "Choose your setup"
  print_phase_intro 2

  # Bundle selection
  local options=()
  local i=0
  for name in "${BUNDLE_NAMES[@]}"; do
    options+=("$(printf '%-12s — %s' "$name" "${BUNDLE_DESCS[$i]}")")
    ((i++))
  done

  local bundle
  bundle=$(ui_choose "Select a setup bundle:" "${options[@]}")

  local bundle_key
  bundle_key=$(echo "$bundle" | awk '{print tolower($1)}')
  [[ "$bundle_key" == "web" ]] && bundle_key="web-dev"

  log "Bundle selected: $bundle_key"

  if [[ "$bundle_key" == "custom" ]]; then
    select_custom
  else
    select_bundle "$bundle_key"
    show_bundle_summary "$bundle_key"
  fi

  # Shell config — always offered (not just custom)
  select_shell_config

  # Configuration options — always offered
  select_configuration
}

show_bundle_summary() {
  local bundle="$1"
  echo ""
  echo -e "  ${BOLD}Bundle includes:${RESET}"

  if [[ ${#SELECTED_APPS[@]} -gt 0 ]]; then
    local app_names=""
    for e in "${SELECTED_APPS[@]}"; do
      local n
      n=$(get_field "$e" 2)
      if [[ -z "$app_names" ]]; then
        app_names="$n"
      else
        app_names="$app_names, $n"
      fi
    done
    echo -e "    ${WHITE}Apps:${RESET} ${app_names}"
  fi
  if [[ ${#SELECTED_DEVTOOLS[@]} -gt 0 ]]; then
    local tool_names=""
    for e in "${SELECTED_DEVTOOLS[@]}"; do
      local n
      n=$(get_field "$e" 2)
      if [[ -z "$tool_names" ]]; then
        tool_names="$n"
      else
        tool_names="$tool_names, $n"
      fi
    done
    echo -e "    ${WHITE}Dev Tools:${RESET} ${tool_names}"
  fi
  if [[ ${#SELECTED_EXTENSIONS[@]} -gt 0 ]]; then
    echo -e "    ${WHITE}Extensions:${RESET} ${#SELECTED_EXTENSIONS[@]} VS Code extensions"
  fi
  if [[ ${#SELECTED_SYSTEM[@]} -gt 0 ]]; then
    echo -e "    ${WHITE}System:${RESET} ${#SELECTED_SYSTEM[@]} macOS settings"
  fi
  if [[ "$INSTALL_NODE" == "true" ]]; then
    echo -e "    ${WHITE}Node.js:${RESET} LTS via NVM + npm globals"
  fi
  echo ""

  if ui_confirm "Would you like to customize this selection?"; then
    customize_bundle
  fi
}

customize_bundle() {
  echo ""
  local what
  what=$(ui_choose_multi "What would you like to customize?" \
    "Apps            — Add or remove applications" \
    "Dev Tools       — Add or remove CLI tools" \
    "Extensions      — Add or remove VS Code extensions" \
    "System Settings — Choose which settings to apply")

  if echo "$what" | grep -q "Apps"; then
    select_apps
  fi
  if echo "$what" | grep -q "Dev Tools"; then
    select_devtools
  fi
  if echo "$what" | grep -q "Extensions"; then
    select_extensions
  fi
  if echo "$what" | grep -q "System Settings"; then
    select_system_settings
  fi
}

select_bundle() {
  local bundle="$1"

  # Apps
  local app_list
  app_list=$(get_bundle_apps "$bundle")
  if [[ "$app_list" == "ALL" ]]; then
    for entry in "${APP_ENTRIES[@]}"; do
      SELECTED_APPS+=("$entry")
    done
  else
    for key in $app_list; do
      for entry in "${APP_ENTRIES[@]}"; do
        local ekey
        ekey=$(get_field "$entry" 1)
        if [[ "$ekey" == "$key" ]]; then
          SELECTED_APPS+=("$entry")
          break
        fi
      done
    done
  fi

  # Dev tools
  local devtool_list
  devtool_list=$(get_bundle_devtools "$bundle")
  if [[ "$devtool_list" == "ALL" ]]; then
    for entry in "${DEVTOOL_ENTRIES[@]}"; do
      SELECTED_DEVTOOLS+=("$entry")
    done
  else
    for key in $devtool_list; do
      for entry in "${DEVTOOL_ENTRIES[@]}"; do
        local ekey
        ekey=$(get_field "$entry" 1)
        if [[ "$ekey" == "$key" ]]; then
          SELECTED_DEVTOOLS+=("$entry")
          break
        fi
      done
    done
  fi

  # Extensions
  local ext_list
  ext_list=$(get_bundle_exts "$bundle")
  if [[ "$ext_list" == "ALL" ]]; then
    for entry in "${EXT_ENTRIES[@]}"; do
      SELECTED_EXTENSIONS+=("$entry")
    done
  else
    for key in $ext_list; do
      for entry in "${EXT_ENTRIES[@]}"; do
        local ekey
        ekey=$(get_field "$entry" 1)
        if [[ "$ekey" == "$key" ]]; then
          SELECTED_EXTENSIONS+=("$entry")
          break
        fi
      done
    done
  fi

  # System settings — ask for web-dev and full instead of auto-including
  if [[ "$bundle" == "web-dev" || "$bundle" == "full" ]]; then
    if ui_confirm "Apply recommended macOS system settings (Dock, Finder, Desktop)?"; then
      for entry in "${SYSTEM_ENTRIES[@]}"; do
        SELECTED_SYSTEM+=("$entry")
      done
    fi
  fi

  # Node for web-dev and full
  if [[ "$bundle" == "web-dev" || "$bundle" == "full" ]]; then
    INSTALL_NODE=true
    INSTALL_NPM_GLOBALS=true
  fi
}

select_custom() {
  print_step "3" "6" "Custom selection"

  local categories
  categories=$(ui_choose_multi "Select categories to configure:" \
    "Apps            — macOS applications" \
    "Dev Tools       — CLI tools and runtimes" \
    "VS Code         — Editor and extensions" \
    "System Settings — macOS preferences")

  local has_selection=false

  if echo "$categories" | grep -q "Apps"; then
    select_apps
    has_selection=true
  fi

  if echo "$categories" | grep -q "Dev Tools"; then
    select_devtools
    has_selection=true
  fi

  if echo "$categories" | grep -q "VS Code"; then
    select_extensions
    has_selection=true
  fi

  if echo "$categories" | grep -q "System Settings"; then
    select_system_settings
    has_selection=true
  fi

  if [[ "$has_selection" == "false" ]]; then
    echo ""
    print_warn "No categories selected. You can still configure Git, SSH, and shell below."
  fi
}

select_apps() {
  echo -ne "  ${ARROW} Loading app status..."
  cache_brew_lists
  echo -e "\r\033[K  ${CHECK} App status loaded"

  local options=()
  for entry in "${APP_ENTRIES[@]}"; do
    local name check_type check_value desc
    name=$(get_field "$entry" 2)
    check_type=$(get_field "$entry" 4)
    check_value=$(get_field "$entry" 5)
    desc=$(get_field "$entry" 6)
    local status
    status=$(get_status_label "" "$check_type" "$check_value")
    local icon=" "
    [[ "$status" == "installed" ]] && icon="✓"
    options+=("$(printf '[%s] %-16s — %s' "$icon" "$name" "$desc")")
  done

  local selected
  selected=$(ui_choose_multi_preview "Select apps to install (tip: 'make info <app>' for details):" "${options[@]}")

  SELECTED_APPS=()
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local app_name
    app_name=$(echo "$line" | sed 's/\[.\] *//' | sed 's/ *—.*//' | xargs)
    for entry in "${APP_ENTRIES[@]}"; do
      local name
      name=$(get_field "$entry" 2)
      if [[ "$name" == "$app_name" ]]; then
        SELECTED_APPS+=("$entry")
        break
      fi
    done
  done <<< "$selected"

  print_success "${#SELECTED_APPS[@]} app(s) selected"
}

select_devtools() {
  echo -ne "  ${ARROW} Loading tool status..."
  cache_brew_lists
  echo -e "\r\033[K  ${CHECK} Tool status loaded"

  local options=()
  for entry in "${DEVTOOL_ENTRIES[@]}"; do
    local name check_type check_value desc
    name=$(get_field "$entry" 2)
    check_type=$(get_field "$entry" 4)
    check_value=$(get_field "$entry" 5)
    desc=$(get_field "$entry" 6)
    local status
    status=$(get_status_label "" "$check_type" "$check_value")
    local icon=" "
    [[ "$status" == "installed" ]] && icon="✓"
    options+=("$(printf '[%s] %-16s — %s' "$icon" "$name" "$desc")")
  done

  local selected
  selected=$(ui_choose_multi_preview "Select dev tools (tip: 'make info <tool>' for details):" "${options[@]}")

  SELECTED_DEVTOOLS=()
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local tool_name
    tool_name=$(echo "$line" | sed 's/\[.\] *//' | sed 's/ *—.*//' | xargs)
    for entry in "${DEVTOOL_ENTRIES[@]}"; do
      local name
      name=$(get_field "$entry" 2)
      if [[ "$name" == "$tool_name" ]]; then
        SELECTED_DEVTOOLS+=("$entry")
        break
      fi
    done
  done <<< "$selected"

  print_success "${#SELECTED_DEVTOOLS[@]} tool(s) selected"

  # Ask about Node if NVM selected
  for entry in "${SELECTED_DEVTOOLS[@]}"; do
    local key
    key=$(get_field "$entry" 1)
    if [[ "$key" == "nvm" ]]; then
      if ui_confirm "Install Node.js LTS via NVM?"; then
        INSTALL_NODE=true
        if ui_confirm "Install global npm packages (lite-server, http-server, license, gitignore)?"; then
          INSTALL_NPM_GLOBALS=true
        fi
      fi
      break
    fi
  done
}

select_extensions() {
  echo -ne "  ${ARROW} Loading extension status..."
  cache_vscode_extensions
  echo -e "\r\033[K  ${CHECK} Extension status loaded"

  local options=()
  local current_cat=""

  for entry in "${EXT_ENTRIES[@]}"; do
    local name ext_id desc cat
    name=$(get_field "$entry" 2)
    ext_id=$(get_field "$entry" 3)
    desc=$(get_field "$entry" 4)
    cat=$(get_field "$entry" 5)

    if [[ "$cat" != "$current_cat" ]]; then
      local cat_label
      cat_label=$(echo "$cat" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
      options+=("$(printf '\033[2m── %s ──\033[0m' "$cat_label")")
      current_cat="$cat"
    fi

    local icon=" "
    if is_vscode_extension_installed "$ext_id"; then
      icon="✓"
    fi
    options+=("$(printf '[%s] %-28s — %s' "$icon" "$name" "$desc")")
  done

  local selected
  selected=$(ui_choose_multi_preview "Select VS Code extensions (tip: 'make info <ext>' for details):" "${options[@]}")

  SELECTED_EXTENSIONS=()
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ "$line" == ──* || "$line" == *"──"* ]] && continue
    local ext_name
    ext_name=$(echo "$line" | sed 's/\[.\] *//' | sed 's/ *—.*//' | xargs)
    for entry in "${EXT_ENTRIES[@]}"; do
      local name
      name=$(get_field "$entry" 2)
      if [[ "$name" == "$ext_name" ]]; then
        SELECTED_EXTENSIONS+=("$entry")
        break
      fi
    done
  done <<< "$selected"

  print_success "${#SELECTED_EXTENSIONS[@]} extension(s) selected"
}

select_system_settings() {
  local options=()
  for entry in "${SYSTEM_ENTRIES[@]}"; do
    local label
    label=$(get_field "$entry" 2)
    options+=("$label")
  done

  local selected
  selected=$(ui_choose_multi "Select macOS settings to apply:" "${options[@]}")

  SELECTED_SYSTEM=()
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    for entry in "${SYSTEM_ENTRIES[@]}"; do
      local label
      label=$(get_field "$entry" 2)
      if [[ "$label" == "$line" ]]; then
        SELECTED_SYSTEM+=("$entry")
        break
      fi
    done
  done <<< "$selected"

  print_success "${#SELECTED_SYSTEM[@]} setting(s) selected"
}

select_shell_config() {
  echo ""
  if ! ui_confirm "Configure shell aliases and plugins?"; then
    return
  fi

  local options
  options=$(ui_choose_multi "Select shell configuration:" \
    "Git aliases     — Shortcuts for common git commands" \
    "General aliases — Shortcuts (clear, open, ls, etc.)" \
    "Docker aliases  — Docker and compose shortcuts" \
    "pnpm aliases    — pnpm package manager shortcuts" \
    "Oh My Zsh plugins — autosuggestions, syntax-highlighting")

  SELECTED_SHELL_OPTIONS=()
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local opt_key
    opt_key=$(echo "$line" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
    SELECTED_SHELL_OPTIONS+=("$opt_key")
  done <<< "$options"
}

select_configuration() {
  echo ""
  # Git configuration — show existing values if set
  local existing_name existing_email
  existing_name=$(git config --global user.name 2>/dev/null || echo "")
  existing_email=$(git config --global user.email 2>/dev/null || echo "")

  if [[ -n "$existing_name" && -n "$existing_email" ]]; then
    echo -e "  ${DIM}Current Git config: ${existing_name} <${existing_email}>${RESET}"
    if ui_confirm "Reconfigure Git (name, email, default branch)?"; then
      CONFIGURE_GIT=true
    fi
  else
    if ui_confirm "Configure Git (name, email, default branch)?"; then
      CONFIGURE_GIT=true
    fi
  fi

  # SSH key
  if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
    echo -e "  ${DIM}SSH key already exists at ~/.ssh/id_ed25519${RESET}"
  else
    if ui_confirm "Generate SSH key for GitHub?"; then
      CONFIGURE_SSH=true
    fi
  fi

  # VS Code settings
  if is_vscode_installed; then
    local settings_file="$HOME/Library/Application Support/Code/User/settings.json"
    if [[ -f "$settings_file" ]]; then
      echo -e "  ${DIM}VS Code settings found at ~/Library/Application Support/Code/User/settings.json${RESET}"
      if ui_confirm "Merge recommended VS Code settings (format on save, Prettier, ESLint, Tailwind, etc.)?"; then
        CONFIGURE_VSCODE_SETTINGS=true
      fi
    else
      if ui_confirm "Apply recommended VS Code settings (format on save, Prettier, ESLint, Tailwind, etc.)?"; then
        CONFIGURE_VSCODE_SETTINGS=true
      fi
    fi
  fi

  # Default browser
  if ui_confirm "Set a default browser?"; then
    select_default_browser
  fi
}

select_default_browser() {
  # Detect installed browsers
  local browsers=()
  [[ -d "/Applications/Arc.app" ]] && browsers+=("Arc")
  [[ -d "/Applications/Google Chrome.app" ]] && browsers+=("Google Chrome")
  [[ -d "/Applications/Firefox.app" ]] && browsers+=("Firefox")
  [[ -d "/Applications/Brave Browser.app" ]] && browsers+=("Brave")
  [[ -d "/Applications/Microsoft Edge.app" ]] && browsers+=("Microsoft Edge")
  [[ -d "/Applications/Safari.app" ]] && browsers+=("Safari")

  if [[ ${#browsers[@]} -eq 0 ]]; then
    print_warn "No supported browsers detected"
    return
  fi

  local selected
  selected=$(ui_choose "Select your default browser:" "${browsers[@]}")

  if [[ -n "$selected" ]]; then
    CONFIGURE_DEFAULT_BROWSER=true
    DEFAULT_BROWSER="$selected"
  fi
}
