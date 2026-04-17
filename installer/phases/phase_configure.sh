#!/usr/bin/env bash
# Phase 6: Post-install configuration

run_phase_configure() {
  print_step "6" "6" "Configuration"
  print_phase_intro 6

  [[ "$CONFIGURE_GIT" == "true" ]] && configure_git
  [[ "$CONFIGURE_SSH" == "true" ]] && configure_ssh
  [[ ${#SELECTED_SHELL_OPTIONS[@]} -gt 0 ]] && configure_shell

  # Oh My Zsh plugins
  local has_omz=false
  for entry in "${SELECTED_DEVTOOLS[@]}"; do
    local key
    key=$(get_field "$entry" 1)
    [[ "$key" == "oh-my-zsh" ]] && has_omz=true
  done
  [[ "$has_omz" == "true" ]] && is_oh_my_zsh_installed && configure_omz_plugins

  [[ ${#SELECTED_SYSTEM[@]} -gt 0 ]] && configure_system
  [[ "$CONFIGURE_VSCODE_SETTINGS" == "true" ]] && configure_vscode_settings
  [[ "$CONFIGURE_DEFAULT_BROWSER" == "true" ]] && configure_default_browser
}

configure_git() {
  print_header "Git Configuration"

  # Show existing values and pre-fill
  local existing_name existing_email
  existing_name=$(git config --global user.name 2>/dev/null || echo "")
  existing_email=$(git config --global user.email 2>/dev/null || echo "")

  local placeholder_name="Your Name"
  local placeholder_email="your@email.com"
  [[ -n "$existing_name" ]] && placeholder_name="$existing_name"
  [[ -n "$existing_email" ]] && placeholder_email="$existing_email"

  if [[ -n "$existing_name" || -n "$existing_email" ]]; then
    echo -e "  ${DIM}Current: ${existing_name:-<not set>} <${existing_email:-<not set>}>${RESET}"
    echo -e "  ${DIM}Press Enter to keep current values${RESET}"
  fi

  local git_name
  git_name=$(ui_input "$placeholder_name" "Git user.name")
  if [[ -n "$git_name" ]]; then
    git config --global user.name "$git_name"
    print_success "user.name = $git_name"
  elif [[ -n "$existing_name" ]]; then
    print_skip "user.name kept: $existing_name"
  fi

  local git_email
  git_email=$(ui_input "$placeholder_email" "Git user.email")
  if [[ -n "$git_email" ]]; then
    git config --global user.email "$git_email"
    print_success "user.email = $git_email"
  elif [[ -n "$existing_email" ]]; then
    print_skip "user.email kept: $existing_email"
  fi

  # Default branch — show current and let user choose
  local current_default
  current_default=$(git config --global init.defaultBranch 2>/dev/null || echo "")
  if [[ -n "$current_default" && "$current_default" != "main" ]]; then
    echo -e "  ${DIM}Current default branch: ${current_default}${RESET}"
    if ui_confirm "Change default branch to 'main'?"; then
      git config --global init.defaultBranch main
      print_success "init.defaultBranch = main"
    else
      print_skip "init.defaultBranch kept: $current_default"
    fi
  else
    git config --global init.defaultBranch main
    print_success "init.defaultBranch = main"
  fi

  log "Git configured: ${git_name:-$existing_name} <${git_email:-$existing_email}>"
}

configure_ssh() {
  print_header "SSH Key Setup"

  local email
  email=$(git config --global user.email 2>/dev/null)
  if [[ -z "$email" ]]; then
    email=$(ui_input "your@email.com" "Email for SSH key")
  fi

  if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
    print_skip "SSH key already exists at ~/.ssh/id_ed25519"
    return
  fi

  ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519" -N ""
  print_success "SSH key generated"

  eval "$(ssh-agent -s)" >/dev/null 2>&1

  mkdir -p "$HOME/.ssh"
  if ! grep -q "github.com" "$HOME/.ssh/config" 2>/dev/null; then
    cat >> "$HOME/.ssh/config" << 'SSHEOF'

Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
SSHEOF
    print_success "SSH config updated"
  fi

  ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" 2>/dev/null
  print_success "Key added to keychain"

  pbcopy < "$HOME/.ssh/id_ed25519.pub"
  echo ""
  print_info "Public key copied to clipboard!"
  print_info "Go to: GitHub → Settings → SSH Keys → New SSH Key → paste"
  log "SSH key generated for $email"
}

configure_shell() {
  print_header "Shell Configuration"

  backup_file "$HOME/.zshrc"

  local alias_block=""

  for opt in "${SELECTED_SHELL_OPTIONS[@]}"; do
    case "$opt" in
      git)
        alias_block+=$(generate_alias_block "Git aliases" "${GIT_ALIAS_ENTRIES[@]}")
        alias_block+=$'\n'
        print_success "Git aliases added"
        ;;
      general)
        alias_block+=$(generate_alias_block "General aliases" "${GENERAL_ALIAS_ENTRIES[@]}")
        alias_block+=$'\n'
        print_success "General aliases added"
        ;;
      docker)
        alias_block+=$(generate_alias_block "Docker aliases" "${DOCKER_ALIAS_ENTRIES[@]}")
        alias_block+=$'\n'
        print_success "Docker aliases added"
        ;;
      pnpm)
        alias_block+=$(generate_alias_block "pnpm aliases" "${PNPM_ALIAS_ENTRIES[@]}")
        alias_block+=$'\n'
        print_success "pnpm aliases added"
        ;;
      oh)
        # Handled in configure_omz_plugins
        ;;
    esac
  done

  if [[ -n "$alias_block" ]]; then
    add_to_file_between_markers "$HOME/.zshrc" "$alias_block"
    print_success "Aliases written to ~/.zshrc"
  fi

  log "Shell configured with: ${SELECTED_SHELL_OPTIONS[*]}"
}

configure_omz_plugins() {
  print_header "Oh My Zsh Plugins"

  install_omz_custom_plugins

  local new_plugins="$OMZ_BUILTIN_PLUGINS"

  # Add custom plugins if selected
  for opt in "${SELECTED_SHELL_OPTIONS[@]}"; do
    if [[ "$opt" == "oh" ]]; then
      new_plugins="$new_plugins $OMZ_CUSTOM_PLUGINS"
      break
    fi
  done

  # Merge with existing plugins to preserve user's custom ones
  if grep -q "^plugins=" "$HOME/.zshrc" 2>/dev/null; then
    local existing_plugins
    existing_plugins=$(grep "^plugins=" "$HOME/.zshrc" | sed 's/plugins=(\(.*\))/\1/')

    local merged="$new_plugins"
    for p in $existing_plugins; do
      if ! echo " $merged " | grep -q " $p "; then
        merged="$merged $p"
      fi
    done

    sed -i '' "s/^plugins=(.*/plugins=(${merged})/" "$HOME/.zshrc"
    new_plugins="$merged"
  fi

  for p in $new_plugins; do
    print_success "Plugin: $p"
  done

  log "OMZ plugins: ${new_plugins}"
}

configure_system() {
  print_header "macOS System Settings"

  echo -e "  ${DIM}The following settings will be applied:${RESET}"
  for entry in "${SELECTED_SYSTEM[@]}"; do
    local label
    label=$(get_field "$entry" 2)
    echo -e "    ${ARROW} ${label}"
  done
  echo ""

  local has_dock_autohide=false

  for entry in "${SELECTED_SYSTEM[@]}"; do
    local key label
    key=$(get_field "$entry" 1)
    label=$(get_field "$entry" 2)
    apply_system_setting "$entry"
    print_success "$label"
    [[ "$key" == "dock-autohide" ]] && has_dock_autohide=true
  done

  if [[ "$has_dock_autohide" == "true" ]]; then
    apply_dock_speed
    print_success "Dock: Removed auto-hide delay"
  fi

  echo ""
  print_warn "Dock and Finder will restart to apply changes..."
  restart_affected_apps
  print_success "Dock and Finder restarted"

  log "System settings applied"
}

configure_vscode_settings() {
  print_header "VS Code Settings"

  local settings_dir="$HOME/Library/Application Support/Code/User"
  local settings_file="$settings_dir/settings.json"
  local recommended="${INSTALLER_ROOT}/installer/config/vscode-settings.json"

  mkdir -p "$settings_dir"

  if [[ -f "$settings_file" ]]; then
    # Deep merge: existing keys preserved, new keys added
    backup_file "$settings_file"
    if jq -s '.[0] * .[1]' "$settings_file" "$recommended" > "$settings_dir/settings.tmp.json" 2>/dev/null; then
      mv "$settings_dir/settings.tmp.json" "$settings_file"
      print_success "Settings merged (existing values preserved)"
    else
      print_error "Failed to merge settings (jq error)"
      rm -f "$settings_dir/settings.tmp.json"
      log "FAILED: VS Code settings merge"
      return
    fi
  else
    cp "$recommended" "$settings_file"
    print_success "Settings created"
  fi

  # Show what was applied
  echo -e "  ${DIM}Key settings applied:${RESET}"
  echo -e "    ${ARROW} Format on save with Prettier"
  echo -e "    ${ARROW} ESLint auto-fix on save"
  echo -e "    ${ARROW} Fira Code with ligatures"
  echo -e "    ${ARROW} Tailwind CSS IntelliSense"
  echo -e "    ${ARROW} Emmet in JSX/TSX"
  echo -e "    ${ARROW} File nesting (package.json groups config files)"
  echo -e "    ${ARROW} Sidebar on right, minimap off, sticky scroll on"
  echo -e "  ${DIM}File: ${settings_file}${RESET}"

  log "VS Code settings configured"
}

configure_default_browser() {
  print_header "Default Browser"

  # Map display name to defaultbrowser short name
  local browser_key=""
  case "$DEFAULT_BROWSER" in
    "Arc")              browser_key="browser" ;;
    "Google Chrome")    browser_key="chrome" ;;
    "Firefox")          browser_key="firefox" ;;
    "Brave")            browser_key="brave" ;;
    "Microsoft Edge")   browser_key="edge" ;;
    "Safari")           browser_key="safari" ;;
  esac

  if [[ -z "$browser_key" ]]; then
    print_error "Unknown browser: $DEFAULT_BROWSER"
    return
  fi

  # Install defaultbrowser if needed
  if ! command -v defaultbrowser &>/dev/null; then
    echo -ne "  ${ARROW} Installing defaultbrowser utility..."
    if brew install defaultbrowser >>"$LOG_FILE" 2>&1; then
      echo -e "\r\033[K  ${CHECK} defaultbrowser installed"
    else
      echo -e "\r\033[K  ${CROSS} Failed to install defaultbrowser"
      print_info "Set your default browser manually in System Settings → Desktop & Dock"
      log "FAILED: defaultbrowser install"
      return
    fi
  fi

  echo -e "  ${ARROW} Setting ${BOLD}${DEFAULT_BROWSER}${RESET} as default browser..."
  echo -e "  ${DIM}macOS will show a confirmation dialog — click \"Use ${DEFAULT_BROWSER}\"${RESET}"

  defaultbrowser "$browser_key" 2>>"$LOG_FILE"
  print_success "Default browser set to $DEFAULT_BROWSER"

  log "Default browser: $DEFAULT_BROWSER ($browser_key)"
}
