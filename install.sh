#!/usr/bin/env bash
set -eo pipefail

# ── Brewkit Installer ──
# Interactive CLI installer for your dev environment
# Usage: make install  (or  bash install.sh [--dry-run] [--verbose])

INSTALLER_VERSION="1.0.0"
INSTALLER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USE_FALLBACK=false
DRY_RUN=false
VERBOSE=false

# Parse flags
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --verbose) VERBOSE=true ;;
    --help|-h) echo "Usage: bash install.sh [--dry-run] [--verbose]"; exit 0 ;;
  esac
done

# ── Source all modules ──
source "${INSTALLER_ROOT}/installer/lib/colors.sh"
source "${INSTALLER_ROOT}/installer/lib/log.sh"
source "${INSTALLER_ROOT}/installer/lib/utils.sh"
source "${INSTALLER_ROOT}/installer/lib/checks.sh"
source "${INSTALLER_ROOT}/installer/lib/ui.sh"
source "${INSTALLER_ROOT}/installer/lib/flair.sh"
source "${INSTALLER_ROOT}/installer/registry/apps.sh"
source "${INSTALLER_ROOT}/installer/registry/dev-tools.sh"
source "${INSTALLER_ROOT}/installer/registry/editor.sh"
source "${INSTALLER_ROOT}/installer/registry/shell.sh"
source "${INSTALLER_ROOT}/installer/registry/system.sh"
source "${INSTALLER_ROOT}/installer/bundles.sh"
source "${INSTALLER_ROOT}/installer/phases/phase_prerequisites.sh"
source "${INSTALLER_ROOT}/installer/phases/phase_select.sh"
source "${INSTALLER_ROOT}/installer/phases/phase_resolve.sh"
source "${INSTALLER_ROOT}/installer/phases/phase_install.sh"
source "${INSTALLER_ROOT}/installer/phases/phase_configure.sh"

# ── Init ──
init_log
start_timer

# ── Check macOS ──
if [[ "$(uname)" != "Darwin" ]]; then
  print_error "This installer is for macOS only."
  exit 1
fi

# ── Banner ──
print_banner
echo -e "  ${DIM}macOS $(get_macos_version) | $(get_arch) | v${INSTALLER_VERSION}${RESET}"
echo ""
echo -e "  ${DIM}This installer will walk you through setting up your Mac.${RESET}"
echo -e "  ${DIM}You'll choose what to install and every step requires your approval.${RESET}"
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "  ${WARN} ${YELLOW}DRY RUN MODE — no changes will be made${RESET}"
  echo ""
fi

if [[ "$VERBOSE" == "true" ]]; then
  echo -e "  ${INFO} ${DIM}Verbose mode — showing command output${RESET}"
  echo ""
fi

# ── Dry run preview function ──
show_dry_run_preview() {
  echo ""
  print_header "Dry Run Preview"

  if [[ ${#PLAN_INSTALL[@]} -gt 0 ]]; then
    echo -e "  ${BOLD}Commands that would be executed:${RESET}"
    echo ""
    local plan_item type entry name brew_args install_method ext_id
    for plan_item in "${PLAN_INSTALL[@]}"; do
      type="${plan_item%%|*}"
      entry="${plan_item#*|}"
      case "$type" in
        app)
          name=$(get_field "$entry" 2)
          brew_args=$(get_field "$entry" 3)
          echo -e "    ${DIM}brew install ${brew_args}${RESET}  ${GRAY}# ${name}${RESET}"
          ;;
        devtool)
          name=$(get_field "$entry" 2)
          install_method=$(get_field "$entry" 3)
          local method_type="${install_method%%:*}"
          local method_value="${install_method#*:}"
          case "$method_type" in
            brew) echo -e "    ${DIM}brew install ${method_value}${RESET}  ${GRAY}# ${name}${RESET}" ;;
            cask) echo -e "    ${DIM}brew install --cask ${method_value}${RESET}  ${GRAY}# ${name}${RESET}" ;;
            *)    echo -e "    ${DIM}${install_method}${RESET}  ${GRAY}# ${name}${RESET}" ;;
          esac
          ;;
        vscode)
          echo -e "    ${DIM}brew install --cask visual-studio-code${RESET}  ${GRAY}# VS Code${RESET}"
          ;;
        ext)
          name=$(get_field "$entry" 2)
          ext_id=$(get_field "$entry" 3)
          echo -e "    ${DIM}code --install-extension ${ext_id}${RESET}  ${GRAY}# ${name}${RESET}"
          ;;
      esac
    done
  fi

  if [[ ${#SELECTED_SYSTEM[@]} -gt 0 ]]; then
    echo ""
    echo -e "  ${BOLD}System settings that would be applied:${RESET}"
    echo ""
    local label domain setting_key value_type value
    for entry in "${SELECTED_SYSTEM[@]}"; do
      label=$(get_field "$entry" 2)
      domain=$(get_field "$entry" 3)
      setting_key=$(get_field "$entry" 4)
      value_type=$(get_field "$entry" 5)
      value=$(get_field "$entry" 6)
      echo -e "    ${DIM}defaults write ${domain} ${setting_key} -${value_type} ${value}${RESET}  ${GRAY}# ${label}${RESET}"
    done
  fi

  if [[ "$CONFIGURE_GIT" == "true" ]]; then
    echo ""
    echo -e "    ${DIM}git config --global ...${RESET}  ${GRAY}# Git name, email, default branch${RESET}"
  fi
  if [[ "$CONFIGURE_SSH" == "true" ]]; then
    echo -e "    ${DIM}ssh-keygen -t ed25519 ...${RESET}  ${GRAY}# SSH key for GitHub${RESET}"
  fi
  if [[ ${#SELECTED_SHELL_OPTIONS[@]} -gt 0 ]]; then
    echo -e "    ${DIM}~/.zshrc modifications${RESET}  ${GRAY}# Shell aliases: ${SELECTED_SHELL_OPTIONS[*]}${RESET}"
  fi
  if [[ "$CONFIGURE_VSCODE_SETTINGS" == "true" ]]; then
    echo -e "    ${DIM}~/Library/.../Code/User/settings.json${RESET}  ${GRAY}# VS Code recommended settings${RESET}"
  fi
  if [[ "$CONFIGURE_DEFAULT_BROWSER" == "true" ]]; then
    echo -e "    ${DIM}defaultbrowser ${DEFAULT_BROWSER}${RESET}  ${GRAY}# Set default browser${RESET}"
  fi

  echo ""
  local elapsed
  elapsed=$(get_elapsed)
  echo -e "  ${DIM}○ Dry run complete in ${elapsed} — no changes were made${RESET}"
}

# ── Run phases ──
run_phase_prerequisites
run_phase_select
run_phase_resolve

if [[ "$DRY_RUN" == "true" ]]; then
  show_dry_run_preview
  exit 0
fi

run_phase_install
run_phase_configure

# ── Completion ──
print_completion_banner "${#RESULTS_SUCCESS[@]}" "${#RESULTS_FAILED[@]}"

if [[ ${#RESULTS_SUCCESS[@]} -gt 0 ]]; then
  echo -e "  ${GREEN}${BOLD}Installed (${#RESULTS_SUCCESS[@]}):${RESET}"
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
  print_info "Check logs for details: ${LOG_FILE}"
  echo ""
fi

# Post-install next steps
echo -e "  ${BOLD}Next steps:${RESET}"
echo -e "    ${ARROW} Restart your terminal to apply shell changes"
if [[ "$CONFIGURE_SSH" == "true" ]]; then
  echo -e "    ${ARROW} Add SSH key to GitHub (already copied to clipboard)"
  echo -e "      ${DIM}GitHub → Settings → SSH Keys → New SSH Key → paste${RESET}"
fi
echo -e "    ${ARROW} Grant permissions to new apps (Accessibility, Screen Recording)"
if [[ ${#RESULTS_FAILED[@]} -gt 0 ]]; then
  echo -e "    ${ARROW} Re-run ${DIM}make install${RESET} to retry failed items"
fi
echo -e "    ${ARROW} Log file: ${DIM}${LOG_FILE}${RESET}"
echo ""

# Offer to save selections for replay on another machine
if ui_confirm "Save your selections for easy replay on another machine?"; then
  export_selections "${INSTALLER_ROOT}/my-selections.sh"
  print_success "Selections saved to my-selections.sh"
  echo ""
fi
