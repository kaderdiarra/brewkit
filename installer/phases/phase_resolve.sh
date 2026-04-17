#!/usr/bin/env bash
# Phase 4: Dependency resolution and install plan

PLAN_INSTALL=()
PLAN_SKIP=()

run_phase_resolve() {
  print_step "4" "6" "Resolving dependencies"
  print_phase_intro 4

  # Pre-cache install status for fast lookups
  echo -ne "  ${ARROW} Checking installed software..."
  cache_brew_lists
  if [[ ${#SELECTED_EXTENSIONS[@]} -gt 0 ]]; then
    cache_vscode_extensions
  fi
  echo -e "\r\033[K  ${CHECK} Install status loaded"
  echo ""

  local total_new=0
  local total_installed=0

  # Check apps
  for entry in "${SELECTED_APPS[@]}"; do
    local name check_type check_value
    name=$(get_field "$entry" 2)
    check_type=$(get_field "$entry" 4)
    check_value=$(get_field "$entry" 5)
    local status
    status=$(get_status_label "" "$check_type" "$check_value")
    if [[ "$status" == "installed" ]]; then
      PLAN_SKIP+=("app|$entry")
      print_skip "$name — already installed"
      ((total_installed++))
    else
      PLAN_INSTALL+=("app|$entry")
      print_arrow "$name — will install"
      ((total_new++))
    fi
  done

  # Check dev tools
  for entry in "${SELECTED_DEVTOOLS[@]}"; do
    local name check_type check_value
    name=$(get_field "$entry" 2)
    check_type=$(get_field "$entry" 4)
    check_value=$(get_field "$entry" 5)
    local status
    status=$(get_status_label "" "$check_type" "$check_value")
    if [[ "$status" == "installed" ]]; then
      PLAN_SKIP+=("devtool|$entry")
      print_skip "$name — already installed"
      ((total_installed++))
    else
      PLAN_INSTALL+=("devtool|$entry")
      print_arrow "$name — will install"
      ((total_new++))
    fi
  done

  # Check VS Code
  if [[ ${#SELECTED_EXTENSIONS[@]} -gt 0 ]]; then
    if ! is_vscode_installed; then
      print_arrow "VS Code — will install (required for extensions)"
      PLAN_INSTALL+=("vscode|install")
      ((total_new++))
    else
      print_skip "VS Code — already installed"
    fi
  fi

  # Check extensions
  for entry in "${SELECTED_EXTENSIONS[@]}"; do
    local name ext_id
    name=$(get_field "$entry" 2)
    ext_id=$(get_field "$entry" 3)
    if is_vscode_extension_installed "$ext_id"; then
      PLAN_SKIP+=("ext|$entry")
      ((total_installed++))
    else
      PLAN_INSTALL+=("ext|$entry")
      ((total_new++))
    fi
  done

  local system_count=${#SELECTED_SYSTEM[@]}
  local config_count=0
  [[ "$CONFIGURE_GIT" == "true" ]] && ((config_count++))
  [[ "$CONFIGURE_SSH" == "true" ]] && ((config_count++))
  [[ ${#SELECTED_SHELL_OPTIONS[@]} -gt 0 ]] && ((config_count++))

  echo ""
  echo -e "  ${BOLD}Plan summary:${RESET}"
  echo -e "    ${GREEN}New installs:${RESET}    $total_new"
  echo -e "    ${GRAY}Already installed:${RESET} $total_installed"
  [[ $system_count -gt 0 ]] && echo -e "    ${WHITE}System settings:${RESET}  $system_count"
  [[ $config_count -gt 0 ]] && echo -e "    ${BLUE}Configurations:${RESET}   $config_count"
  echo ""

  if [[ $total_new -eq 0 && $system_count -eq 0 && $config_count -eq 0 ]]; then
    print_success "Everything is already installed!"
    if ! ui_confirm "Continue with configuration steps?"; then
      exit 0
    fi
  else
    if ! ui_confirm "Proceed with installation?"; then
      echo ""
      print_info "Installation cancelled."
      exit 0
    fi
  fi

  log "Plan: ${#PLAN_INSTALL[@]} to install, ${#PLAN_SKIP[@]} to skip"
}
