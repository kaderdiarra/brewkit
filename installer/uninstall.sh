#!/usr/bin/env bash
# Brewkit — interactive uninstaller
# Usage: make uninstall  (or  bash installer/uninstall.sh [--dry-run])

set -eo pipefail

INSTALLER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=false
USE_FALLBACK=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --help|-h) echo "Usage: bash installer/uninstall.sh [--dry-run]"; exit 0 ;;
  esac
done

# ── Source dependencies ──
source "${INSTALLER_ROOT}/installer/lib/colors.sh"
source "${INSTALLER_ROOT}/installer/lib/log.sh"
source "${INSTALLER_ROOT}/installer/lib/utils.sh"
source "${INSTALLER_ROOT}/installer/lib/checks.sh"
source "${INSTALLER_ROOT}/installer/lib/ui.sh"
source "${INSTALLER_ROOT}/installer/registry/apps.sh"
source "${INSTALLER_ROOT}/installer/registry/dev-tools.sh"
source "${INSTALLER_ROOT}/installer/registry/editor.sh"
source "${INSTALLER_ROOT}/installer/registry/system.sh"

# ── Init ──
LOG_DIR="${INSTALLER_ROOT}/logs"
LOG_FILE="${LOG_DIR}/uninstall-$(date +%Y-%m-%d-%H%M%S).log"
INSTALLER_VERSION="1.0.0"
mkdir -p "$LOG_DIR"
touch "$LOG_FILE"
log "Uninstall started at $(date)"

# ── Deep clean helpers ──

# Detect Homebrew prefix (Intel vs Apple Silicon)
BREW_PREFIX="$(brew --prefix 2>/dev/null || echo "/usr/local")"

# Scans common macOS + Homebrew locations for app/tool leftovers after uninstall
clean_app_leftovers() {
  local app_name="$1"
  local cleaned=0

  # User-level locations where macOS apps store data
  local user_dirs=(
    "$HOME/Library/Application Support"
    "$HOME/Library/Preferences"
    "$HOME/Library/Caches"
    "$HOME/Library/Saved Application State"
    "$HOME/Library/Logs"
    "$HOME/Library/Containers"
    "$HOME/Library/Group Containers"
    "$HOME/Library/HTTPStorages"
    "$HOME/Library/WebKit"
    "$HOME/Library/LaunchAgents"
  )

  # System-level locations where brew formulae/casks leave files
  local system_dirs=(
    "${BREW_PREFIX}/etc"
    "${BREW_PREFIX}/var"
    "${BREW_PREFIX}/opt"
    "${BREW_PREFIX}/share"
  )

  # Normalize app name for matching (lowercase, remove spaces)
  local name_lower
  name_lower=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')
  local name_nospace
  name_nospace=$(echo "$name_lower" | tr -d ' ')

  # Scan user-level directories
  for dir in "${user_dirs[@]}"; do
    [[ ! -d "$dir" ]] && continue
    while IFS= read -r match; do
      [[ -z "$match" ]] && continue
      rm -rf "$match" 2>/dev/null && cleaned=$((cleaned + 1))
      log "CLEANUP: removed $match"
    done < <(find "$dir" -maxdepth 1 \( -iname "*${name_nospace}*" -o -iname "*${name_lower}*" \) 2>/dev/null | sort -u)
  done

  # Scan system-level brew directories
  for dir in "${system_dirs[@]}"; do
    [[ ! -d "$dir" ]] && continue
    while IFS= read -r match; do
      [[ -z "$match" ]] && continue
      rm -rf "$match" 2>/dev/null && cleaned=$((cleaned + 1))
      log "CLEANUP: removed $match"
    done < <(find "$dir" -maxdepth 1 \( -iname "*${name_nospace}*" -o -iname "*${name_lower}*" \) 2>/dev/null | sort -u)
  done

  # Clean stale symlinks in brew bin/sbin that point to removed packages
  local bin_dirs=("${BREW_PREFIX}/bin" "${BREW_PREFIX}/sbin")
  for dir in "${bin_dirs[@]}"; do
    [[ ! -d "$dir" ]] && continue
    while IFS= read -r link; do
      [[ -z "$link" ]] && continue
      # Only remove if it's a broken symlink (target no longer exists)
      if [[ -L "$link" ]] && [[ ! -e "$link" ]]; then
        rm -f "$link" 2>/dev/null && cleaned=$((cleaned + 1))
        log "CLEANUP: removed broken symlink $link"
      fi
    done < <(find "$dir" -maxdepth 1 -iname "*${name_nospace}*" -o -iname "*${name_lower}*" 2>/dev/null)
  done

  # Clean .plist files (preference files by bundle ID pattern)
  while IFS= read -r plist; do
    [[ -z "$plist" ]] && continue
    rm -f "$plist" 2>/dev/null && cleaned=$((cleaned + 1))
    log "CLEANUP: removed $plist"
  done < <(find "$HOME/Library/Preferences" -maxdepth 1 -iname "*${name_nospace}*" -name "*.plist" 2>/dev/null)

  # Clean system-level LaunchAgents/LaunchDaemons
  local launch_dirs=(
    "/Library/LaunchAgents"
    "/Library/LaunchDaemons"
  )
  for dir in "${launch_dirs[@]}"; do
    [[ ! -d "$dir" ]] && continue
    while IFS= read -r plist; do
      [[ -z "$plist" ]] && continue
      # Only log these — removing system launch daemons requires sudo
      log "CLEANUP: found system launch item (manual removal may be needed): $plist"
    done < <(find "$dir" -maxdepth 1 -iname "*${name_nospace}*" -name "*.plist" 2>/dev/null)
  done

  if [[ $cleaned -gt 0 ]]; then
    log "CLEANUP: removed $cleaned leftover(s) for $app_name"
  fi

  return 0
}

# Clean brew formula leftovers specifically (config, var data, opt, broken symlinks)
clean_formula_leftovers() {
  local formula="$1"
  local cleaned=0

  # Remove opt link
  if [[ -d "${BREW_PREFIX}/opt/${formula}" ]]; then
    rm -rf "${BREW_PREFIX}/opt/${formula}" 2>/dev/null && cleaned=$((cleaned + 1))
    log "CLEANUP: removed ${BREW_PREFIX}/opt/${formula}"
  fi

  # Remove etc config (guard against empty BREW_PREFIX expanding to /etc or /var)
  if [[ -n "$BREW_PREFIX" && -d "${BREW_PREFIX}/etc/${formula}" ]]; then
    rm -rf "${BREW_PREFIX:?}/etc/${formula}" 2>/dev/null && cleaned=$((cleaned + 1))
    log "CLEANUP: removed ${BREW_PREFIX}/etc/${formula}"
  fi

  # Remove var data
  if [[ -n "$BREW_PREFIX" && -d "${BREW_PREFIX}/var/${formula}" ]]; then
    rm -rf "${BREW_PREFIX:?}/var/${formula}" 2>/dev/null && cleaned=$((cleaned + 1))
    log "CLEANUP: removed ${BREW_PREFIX}/var/${formula}"
  fi

  # Remove broken symlinks in bin that pointed to this formula
  if [[ -d "${BREW_PREFIX}/bin" ]]; then
    while IFS= read -r link; do
      [[ -z "$link" ]] && continue
      if [[ -L "$link" ]] && [[ ! -e "$link" ]]; then
        rm -f "$link" 2>/dev/null && cleaned=$((cleaned + 1))
        log "CLEANUP: removed broken symlink $link"
      fi
    done < <(find "${BREW_PREFIX}/bin" -maxdepth 1 -lname "*${formula}*" 2>/dev/null)
  fi

  if [[ $cleaned -gt 0 ]]; then
    log "CLEANUP: removed $cleaned formula leftover(s) for $formula"
  fi

  return 0
}

# Get the cask token from brew_args (strip --cask prefix)
get_cask_token() {
  local brew_args="$1"
  echo "${brew_args/--cask /}"
}

# Detect gum/fzf availability
if ! command -v gum &>/dev/null; then
  USE_FALLBACK=true
fi

# ── Banner ──
echo ""
echo -e "  ${BOLD}${WHITE}Brewkit — Uninstaller${RESET}"
echo -e "  ${ASH}────────────────────${RESET}"
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "  ${WARN} ${YELLOW}DRY RUN — no changes will be made${RESET}"
  echo ""
fi

echo -e "  ${DIM}Select items to remove. Only installed items are shown.${RESET}"
echo -e "  ${DIM}Deep clean: removes app data, caches, and preferences too.${RESET}"
echo ""

# ── Scan installed items ──
echo -ne "  ${ARROW} Scanning installed software..."
cache_brew_lists
cache_vscode_extensions
echo -e "\r\033[K  ${CHECK} Scan complete"
echo ""

INSTALLED_APPS=()
INSTALLED_DEVTOOLS=()
INSTALLED_EXTENSIONS=()

for entry in "${APP_ENTRIES[@]}"; do
  check_type=$(get_field "$entry" 4)
  check_value=$(get_field "$entry" 5)
  status=$(get_status_label "" "$check_type" "$check_value")
  if [[ "$status" == "installed" ]]; then
    INSTALLED_APPS+=("$entry")
  fi
done

for entry in "${DEVTOOL_ENTRIES[@]}"; do
  check_type=$(get_field "$entry" 4)
  check_value=$(get_field "$entry" 5)
  status=$(get_status_label "" "$check_type" "$check_value")
  if [[ "$status" == "installed" ]]; then
    INSTALLED_DEVTOOLS+=("$entry")
  fi
done

for entry in "${EXT_ENTRIES[@]}"; do
  ext_id=$(get_field "$entry" 3)
  if is_vscode_extension_installed "$ext_id"; then
    INSTALLED_EXTENSIONS+=("$entry")
  fi
done

total_installed=$(( ${#INSTALLED_APPS[@]} + ${#INSTALLED_DEVTOOLS[@]} + ${#INSTALLED_EXTENSIONS[@]} ))

if [[ $total_installed -eq 0 ]]; then
  echo -e "  ${DIM}No Brewkit-managed items are currently installed.${RESET}"
  echo ""
  exit 0
fi

echo -e "  ${DIM}Found ${BOLD}${total_installed}${RESET}${DIM} installed items across ${#INSTALLED_APPS[@]} apps, ${#INSTALLED_DEVTOOLS[@]} dev tools, ${#INSTALLED_EXTENSIONS[@]} extensions${RESET}"
echo ""

# ── Category selection ──
categories_available=()
[[ ${#INSTALLED_APPS[@]} -gt 0 ]] && categories_available+=("Apps            — ${#INSTALLED_APPS[@]} installed")
[[ ${#INSTALLED_DEVTOOLS[@]} -gt 0 ]] && categories_available+=("Dev Tools       — ${#INSTALLED_DEVTOOLS[@]} installed")
[[ ${#INSTALLED_EXTENSIONS[@]} -gt 0 ]] && categories_available+=("Extensions      — ${#INSTALLED_EXTENSIONS[@]} installed")
categories_available+=("Shell config    — Remove brewkit aliases from ~/.zshrc")

selected_categories=$(ui_choose_multi "What would you like to uninstall?" "${categories_available[@]}")

if [[ -z "$selected_categories" ]]; then
  echo ""
  echo -e "  ${DIM}Nothing selected. Exiting.${RESET}"
  echo ""
  exit 0
fi

# ── Item selection per category ──
REMOVE_APPS=()
REMOVE_DEVTOOLS=()
REMOVE_EXTENSIONS=()
REMOVE_SHELL=false

if echo "$selected_categories" | grep -q "Apps"; then
  options=()
  for entry in "${INSTALLED_APPS[@]}"; do
    name=$(get_field "$entry" 2)
    desc=$(get_field "$entry" 6)
    options+=("$(printf '%-16s — %s' "$name" "$desc")")
  done

  selected=$(ui_choose_multi "Select apps to remove:" "${options[@]}")

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    app_name=$(echo "$line" | sed 's/ *—.*//' | xargs)
    for entry in "${INSTALLED_APPS[@]}"; do
      name=$(get_field "$entry" 2)
      if [[ "$name" == "$app_name" ]]; then
        REMOVE_APPS+=("$entry")
        break
      fi
    done
  done <<< "$selected"

  if [[ ${#REMOVE_APPS[@]} -gt 0 ]]; then
    print_success "${#REMOVE_APPS[@]} app(s) selected for removal"
  fi
fi

if echo "$selected_categories" | grep -q "Dev Tools"; then
  options=()
  for entry in "${INSTALLED_DEVTOOLS[@]}"; do
    name=$(get_field "$entry" 2)
    desc=$(get_field "$entry" 6)
    options+=("$(printf '%-16s — %s' "$name" "$desc")")
  done

  selected=$(ui_choose_multi "Select dev tools to remove:" "${options[@]}")

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    tool_name=$(echo "$line" | sed 's/ *—.*//' | xargs)
    for entry in "${INSTALLED_DEVTOOLS[@]}"; do
      name=$(get_field "$entry" 2)
      if [[ "$name" == "$tool_name" ]]; then
        REMOVE_DEVTOOLS+=("$entry")
        break
      fi
    done
  done <<< "$selected"

  if [[ ${#REMOVE_DEVTOOLS[@]} -gt 0 ]]; then
    print_success "${#REMOVE_DEVTOOLS[@]} tool(s) selected for removal"
  fi
fi

if echo "$selected_categories" | grep -q "Extensions"; then
  options=()
  for entry in "${INSTALLED_EXTENSIONS[@]}"; do
    name=$(get_field "$entry" 2)
    desc=$(get_field "$entry" 4)
    options+=("$(printf '%-28s — %s' "$name" "$desc")")
  done

  selected=$(ui_choose_multi "Select extensions to remove:" "${options[@]}")

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    ext_name=$(echo "$line" | sed 's/ *—.*//' | xargs)
    for entry in "${INSTALLED_EXTENSIONS[@]}"; do
      name=$(get_field "$entry" 2)
      if [[ "$name" == "$ext_name" ]]; then
        REMOVE_EXTENSIONS+=("$entry")
        break
      fi
    done
  done <<< "$selected"

  if [[ ${#REMOVE_EXTENSIONS[@]} -gt 0 ]]; then
    print_success "${#REMOVE_EXTENSIONS[@]} extension(s) selected for removal"
  fi
fi

if echo "$selected_categories" | grep -q "Shell config"; then
  REMOVE_SHELL=true
  print_success "Shell config selected for removal"
fi

# ── Total count check ──
total_remove=$(( ${#REMOVE_APPS[@]} + ${#REMOVE_DEVTOOLS[@]} + ${#REMOVE_EXTENSIONS[@]} ))
if [[ $total_remove -eq 0 && "$REMOVE_SHELL" == "false" ]]; then
  echo ""
  echo -e "  ${DIM}Nothing selected. Exiting.${RESET}"
  echo ""
  exit 0
fi

# ── Preview ──
echo ""
echo -e "  ${BOLD}Removal plan:${RESET}"
echo ""

if [[ ${#REMOVE_APPS[@]} -gt 0 ]]; then
  echo -e "  ${WHITE}Apps:${RESET}  ${DIM}(deep clean — removes app data, caches, preferences)${RESET}"
  for entry in "${REMOVE_APPS[@]}"; do
    name=$(get_field "$entry" 2)
    brew_args=$(get_field "$entry" 3)
    cask_token=$(get_cask_token "$brew_args")
    echo -e "    ${DIM}brew uninstall --zap --cask ${cask_token}${RESET}  ${GRAY}# ${name}${RESET}"
  done
fi

if [[ ${#REMOVE_DEVTOOLS[@]} -gt 0 ]]; then
  echo -e "  ${WHITE}Dev Tools:${RESET}  ${DIM}(includes config, var data, broken symlinks cleanup)${RESET}"
  for entry in "${REMOVE_DEVTOOLS[@]}"; do
    name=$(get_field "$entry" 2)
    install_method=$(get_field "$entry" 3)
    method_type="${install_method%%:*}"
    method_value="${install_method#*:}"
    case "$method_type" in
      brew) echo -e "    ${DIM}brew uninstall ${method_value}${RESET}  ${GRAY}# ${name}${RESET}" ;;
      cask) echo -e "    ${DIM}brew uninstall --zap --cask ${method_value}${RESET}  ${GRAY}# ${name}${RESET}" ;;
      custom)
        key=$(get_field "$entry" 1)
        case "$key" in
          nvm)       echo -e "    ${DIM}rm -rf ~/.nvm${RESET}  ${GRAY}# ${name}${RESET}" ;;
          oh-my-zsh) echo -e "    ${DIM}rm -rf ~/.oh-my-zsh${RESET}  ${GRAY}# ${name}${RESET}" ;;
          *)         echo -e "    ${DIM}manual removal${RESET}  ${GRAY}# ${name}${RESET}" ;;
        esac
        ;;
    esac
  done
fi

if [[ ${#REMOVE_EXTENSIONS[@]} -gt 0 ]]; then
  echo -e "  ${WHITE}Extensions:${RESET}"
  for entry in "${REMOVE_EXTENSIONS[@]}"; do
    name=$(get_field "$entry" 2)
    ext_id=$(get_field "$entry" 3)
    echo -e "    ${DIM}code --uninstall-extension ${ext_id}${RESET}  ${GRAY}# ${name}${RESET}"
  done
fi

if [[ "$REMOVE_SHELL" == "true" ]]; then
  echo -e "  ${WHITE}Shell:${RESET}"
  echo -e "    ${DIM}Remove brewkit blocks (aliases + keys) from ~/.zshrc${RESET}"
fi

echo ""

# ── Dry run exit ──
if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "  ${DIM}○ Dry run complete — no changes were made${RESET}"
  echo ""
  exit 0
fi

# ── Confirmation ──
if ! ui_confirm "Proceed with removal? This cannot be undone."; then
  echo ""
  echo -e "  ${DIM}Uninstall cancelled.${RESET}"
  echo ""
  exit 0
fi

echo ""

# ── Execute removals ──
RESULTS_SUCCESS=()
RESULTS_FAILED=()

# Apps — use --zap for deep cleanup (removes preferences, caches, app support data)
for entry in "${REMOVE_APPS[@]}"; do
  name=$(get_field "$entry" 2)
  brew_args=$(get_field "$entry" 3)
  cask_token=$(get_cask_token "$brew_args")
  echo -ne "  ${ARROW} Removing ${BOLD}${name}${RESET}..."

  # Try --zap first (deep clean), fall back to regular uninstall
  if brew uninstall --zap --cask "$cask_token" >>"$LOG_FILE" 2>&1; then
    clean_app_leftovers "$name"
    echo -e "\r  ${CHECK} ${name} removed (deep clean)       "
    RESULTS_SUCCESS+=("$name")
    log "REMOVED (zap): $name"
  elif brew uninstall --cask "$cask_token" >>"$LOG_FILE" 2>&1; then
    clean_app_leftovers "$name"
    echo -e "\r  ${CHECK} ${name} removed                    "
    RESULTS_SUCCESS+=("$name")
    log "REMOVED: $name"
  else
    echo -e "\r  ${CROSS} ${name} — failed                   "
    RESULTS_FAILED+=("$name")
    log "FAILED to remove: $name"
  fi
done

# Dev tools
for entry in "${REMOVE_DEVTOOLS[@]}"; do
  name=$(get_field "$entry" 2)
  key=$(get_field "$entry" 1)
  install_method=$(get_field "$entry" 3)
  method_type="${install_method%%:*}"
  method_value="${install_method#*:}"

  echo -ne "  ${ARROW} Removing ${BOLD}${name}${RESET}..."

  remove_success=false
  case "$method_type" in
    brew)
      if brew uninstall "$method_value" >>"$LOG_FILE" 2>&1; then
        clean_formula_leftovers "$method_value"
        remove_success=true
      fi
      ;;
    cask)
      if brew uninstall --zap --cask "$method_value" >>"$LOG_FILE" 2>&1; then
        clean_app_leftovers "$name"
        remove_success=true
      elif brew uninstall --cask "$method_value" >>"$LOG_FILE" 2>&1; then
        clean_app_leftovers "$name"
        remove_success=true
      fi
      ;;
    custom)
      case "$key" in
        nvm)
          if [[ -d "$HOME/.nvm" ]]; then
            rm -rf "$HOME/.nvm"
            # Clean NVM lines from shell config
            if [[ -f "$HOME/.zshrc" ]]; then
              sed -i '' '/NVM_DIR/d' "$HOME/.zshrc" 2>/dev/null || true
              sed -i '' '/nvm\.sh/d' "$HOME/.zshrc" 2>/dev/null || true
            fi
            remove_success=true
          fi
          ;;
        oh-my-zsh)
          if [[ -d "$HOME/.oh-my-zsh" ]]; then
            rm -rf "$HOME/.oh-my-zsh"
            # Remove OMZ source line and plugins from .zshrc
            if [[ -f "$HOME/.zshrc" ]]; then
              sed -i '' '/oh-my-zsh\.sh/d' "$HOME/.zshrc" 2>/dev/null || true
              sed -i '' '/ZSH_THEME=/d' "$HOME/.zshrc" 2>/dev/null || true
              sed -i '' '/^plugins=(/,/)/d' "$HOME/.zshrc" 2>/dev/null || true
              sed -i '' '/^export ZSH=/d' "$HOME/.zshrc" 2>/dev/null || true
            fi
            remove_success=true
          fi
          ;;
        *)
          log "No uninstall handler for custom tool: $key"
          ;;
      esac
      ;;
  esac

  if [[ "$remove_success" == "true" ]]; then
    echo -e "\r  ${CHECK} ${name} removed                    "
    RESULTS_SUCCESS+=("$name")
    log "REMOVED: $name"
  else
    echo -e "\r  ${CROSS} ${name} — failed                   "
    RESULTS_FAILED+=("$name")
    log "FAILED to remove: $name"
  fi
done

# Extensions
for entry in "${REMOVE_EXTENSIONS[@]}"; do
  name=$(get_field "$entry" 2)
  ext_id=$(get_field "$entry" 3)
  echo -ne "  ${ARROW} Removing ${BOLD}${name}${RESET}..."

  if code --uninstall-extension "$ext_id" >>"$LOG_FILE" 2>&1; then
    echo -e "\r  ${CHECK} ${name} removed                    "
    RESULTS_SUCCESS+=("$name")
    log "REMOVED: $name"
  else
    echo -e "\r  ${CROSS} ${name} — failed                   "
    RESULTS_FAILED+=("$name")
    log "FAILED to remove: $name"
  fi
done

# Shell config
if [[ "$REMOVE_SHELL" == "true" ]]; then
  removed_any=false
  for block_tag in "brewkit" "brewkit-keys"; do
    marker_start="# >>> ${block_tag} >>>"
    marker_end="# <<< ${block_tag} <<<"
    if [[ -f "$HOME/.zshrc" ]] && grep -q "$marker_start" "$HOME/.zshrc" 2>/dev/null; then
      backup_file "$HOME/.zshrc"
      sed -i '' "/$marker_start/,/$marker_end/d" "$HOME/.zshrc"
      removed_any=true
      log "REMOVED: ${block_tag} block from .zshrc"
    fi
  done
  if [[ "$removed_any" == "true" ]]; then
    print_success "Brewkit shell config removed from ~/.zshrc"
    RESULTS_SUCCESS+=("Shell config")
  else
    echo -e "  ${SKIP} ${GRAY}No brewkit block found in ~/.zshrc${RESET}"
  fi
fi

# ── Summary ──
echo ""
echo -e "  ${ASH}────────────────────${RESET}"
echo ""

if [[ ${#RESULTS_SUCCESS[@]} -gt 0 ]]; then
  echo -e "  ${GREEN}${BOLD}Removed (${#RESULTS_SUCCESS[@]}):${RESET}"
  for item in "${RESULTS_SUCCESS[@]}"; do
    echo -e "    ${CHECK} $item"
  done
  echo ""
fi

if [[ ${#RESULTS_FAILED[@]} -gt 0 ]]; then
  echo -e "  ${RED}${BOLD}Failed (${#RESULTS_FAILED[@]}):${RESET}"
  for item in "${RESULTS_FAILED[@]}"; do
    echo -e "    ${CROSS} $item"
  done
  echo ""
  print_info "Check logs: ${LOG_FILE}"
  echo ""
fi

if [[ ${#RESULTS_SUCCESS[@]} -gt 0 ]]; then
  echo -e "  ${DIM}Restart your terminal to apply shell changes.${RESET}"
  echo ""
fi

log "Uninstall complete: ${#RESULTS_SUCCESS[@]} removed, ${#RESULTS_FAILED[@]} failed"
