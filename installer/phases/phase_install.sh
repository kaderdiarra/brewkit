#!/usr/bin/env bash
# Phase 5: Execute installations

RESULTS_SUCCESS=()
RESULTS_FAILED=()

run_phase_install() {
  print_step "5" "6" "Installing"
  print_phase_intro 5

  local total=${#PLAN_INSTALL[@]}
  local current=0

  for plan_item in "${PLAN_INSTALL[@]}"; do
    ((current++))
    local type="${plan_item%%|*}"
    local entry="${plan_item#*|}"

    case "$type" in
      app)     install_app "$entry" "$current" "$total" ;;
      devtool) install_devtool "$entry" "$current" "$total" ;;
      vscode)  install_vscode "$current" "$total" ;;
      ext)     install_extension "$entry" "$current" "$total" ;;
    esac

    # Show a dev tip every ~15 seconds
    maybe_show_tip
  done

  # Node.js and npm globals (after NVM)
  if [[ "$INSTALL_NODE" == "true" ]] && is_nvm_installed; then
    local flavor
    flavor=$(get_flavor_text)
    echo -e "  ${ARROW} ${flavor} ${BOLD}Node.js LTS${RESET}..."
    if install_node_lts >>"$LOG_FILE" 2>&1; then
      print_success "Node.js LTS installed"
      RESULTS_SUCCESS+=("Node.js LTS")
    else
      print_error "Node.js LTS install failed (check logs)"
      RESULTS_FAILED+=("Node.js LTS")
    fi
  fi

  if [[ "$INSTALL_NPM_GLOBALS" == "true" ]]; then
    local flavor
    flavor=$(get_flavor_text)
    echo -e "  ${ARROW} ${flavor} ${BOLD}npm globals${RESET}..."
    if install_npm_globals >>"$LOG_FILE" 2>&1; then
      print_success "Global npm packages installed"
      RESULTS_SUCCESS+=("npm globals")
    else
      print_error "npm globals install failed (check logs)"
      RESULTS_FAILED+=("npm globals")
    fi
  fi
}

install_app() {
  local entry="$1"
  local current="$2"
  local total="$3"
  local name brew_args check_type check_value
  name=$(get_field "$entry" 2)
  brew_args=$(get_field "$entry" 3)
  check_type=$(get_field "$entry" 4)
  check_value=$(get_field "$entry" 5)

  local flavor
  flavor=$(get_flavor_text)
  echo -ne "  ${ARROW} ${DIM}[${current}/${total}]${RESET} ${flavor} ${BOLD}${name}${RESET}..."

  if [[ "$VERBOSE" == "true" ]]; then
    echo ""
    brew install $brew_args 2>&1 | tee -a "$LOG_FILE"
    local brew_exit=${PIPESTATUS[0]}
  else
    brew install $brew_args >>"$LOG_FILE" 2>&1
    local brew_exit=$?
  fi

  if [[ $brew_exit -eq 0 ]]; then
    echo -e "\r  ${CHECK} ${DIM}[${current}/${total}]${RESET} ${name}                              "
    RESULTS_SUCCESS+=("$name")
    log "SUCCESS: $name"
  else
    echo -e "\r  ${CROSS} ${DIM}[${current}/${total}]${RESET} ${name} — failed                    "
    RESULTS_FAILED+=("$name")
    log "FAILED: $name"
  fi
}

install_devtool() {
  local entry="$1"
  local current="$2"
  local total="$3"
  local name install_method
  name=$(get_field "$entry" 2)
  install_method=$(get_field "$entry" 3)
  local method_type="${install_method%%:*}"
  local method_value="${install_method#*:}"

  local flavor
  flavor=$(get_flavor_text)
  echo -ne "  ${ARROW} ${DIM}[${current}/${total}]${RESET} ${flavor} ${BOLD}${name}${RESET}..."

  local success=false
  case "$method_type" in
    brew)
      if [[ "$VERBOSE" == "true" ]]; then
        echo ""
        brew install "$method_value" 2>&1 | tee -a "$LOG_FILE"
        [[ ${PIPESTATUS[0]} -eq 0 ]] && success=true
      else
        if brew install "$method_value" >>"$LOG_FILE" 2>&1; then
          success=true
        fi
      fi
      ;;
    cask)
      if [[ "$VERBOSE" == "true" ]]; then
        echo ""
        brew install --cask "$method_value" 2>&1 | tee -a "$LOG_FILE"
        [[ ${PIPESTATUS[0]} -eq 0 ]] && success=true
      else
        if brew install --cask "$method_value" >>"$LOG_FILE" 2>&1; then
          success=true
        fi
      fi
      ;;
    custom)
      if [[ "$VERBOSE" == "true" ]]; then
        echo ""
        "$method_value" 2>&1 | tee -a "$LOG_FILE"
        [[ ${PIPESTATUS[0]} -eq 0 ]] && success=true
      else
        if "$method_value" >>"$LOG_FILE" 2>&1; then
          success=true
        fi
      fi
      ;;
  esac

  if $success; then
    echo -e "\r  ${CHECK} ${DIM}[${current}/${total}]${RESET} ${name}                              "
    RESULTS_SUCCESS+=("$name")
    log "SUCCESS: $name"
  else
    echo -e "\r  ${CROSS} ${DIM}[${current}/${total}]${RESET} ${name} — failed                    "
    RESULTS_FAILED+=("$name")
    log "FAILED: $name"
  fi
}

install_vscode() {
  local current="$1"
  local total="$2"

  local flavor
  flavor=$(get_flavor_text)
  echo -ne "  ${ARROW} ${DIM}[${current}/${total}]${RESET} ${flavor} ${BOLD}VS Code${RESET}..."

  if [[ "$VERBOSE" == "true" ]]; then
    echo ""
    brew install --cask visual-studio-code 2>&1 | tee -a "$LOG_FILE"
    local brew_exit=${PIPESTATUS[0]}
  else
    brew install --cask visual-studio-code >>"$LOG_FILE" 2>&1
    local brew_exit=$?
  fi

  if [[ $brew_exit -eq 0 ]]; then
    echo -e "\r  ${CHECK} ${DIM}[${current}/${total}]${RESET} VS Code                              "
    RESULTS_SUCCESS+=("VS Code")
  else
    echo -e "\r  ${CROSS} ${DIM}[${current}/${total}]${RESET} VS Code — failed                    "
    RESULTS_FAILED+=("VS Code")
  fi
}

install_extension() {
  local entry="$1"
  local current="$2"
  local total="$3"
  local name ext_id
  name=$(get_field "$entry" 2)
  ext_id=$(get_field "$entry" 3)

  local flavor
  flavor=$(get_flavor_text)
  echo -ne "  ${ARROW} ${DIM}[${current}/${total}]${RESET} ${flavor} ${BOLD}${name}${RESET}..."

  if code --install-extension "$ext_id" --force >>"$LOG_FILE" 2>&1; then
    echo -e "\r  ${CHECK} ${DIM}[${current}/${total}]${RESET} ${name}                              "
    RESULTS_SUCCESS+=("$name")
  else
    echo -e "\r  ${CROSS} ${DIM}[${current}/${total}]${RESET} ${name}                              "
    RESULTS_FAILED+=("$name")
  fi
}
