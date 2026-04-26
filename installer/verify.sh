#!/usr/bin/env bash
# Verify current install status of all registered tools and apps

INSTALLER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${INSTALLER_ROOT}/installer/lib/colors.sh"
source "${INSTALLER_ROOT}/installer/lib/checks.sh"
source "${INSTALLER_ROOT}/installer/registry/apps.sh"
source "${INSTALLER_ROOT}/installer/registry/dev-tools.sh"
source "${INSTALLER_ROOT}/installer/registry/editor.sh"

echo ""
echo -e "${BOLD}${WHITE}Brewkit — Status Check${RESET}"
echo -e "${WHITE}──────────────────────────────────${RESET}"

# Pre-cache install status
echo -ne "  ${ARROW} Loading install status..."
cache_brew_lists
cache_vscode_extensions
echo -e "\r\033[K  ${CHECK} Install status loaded"

# Apps
echo ""
echo -e "${BOLD}Apps${RESET}"
installed=0
missing=0
for entry in "${APP_ENTRIES[@]}"; do
  local_name=$(get_field "$entry" 2)
  check_type=$(get_field "$entry" 4)
  check_value=$(get_field "$entry" 5)
  status=$(get_status_label "" "$check_type" "$check_value")
  if [[ "$status" == "installed" ]]; then
    echo -e "  ${CHECK} ${local_name}"
    installed=$((installed + 1))
  else
    echo -e "  ${CROSS} ${local_name} ${DIM}— not installed${RESET}"
    missing=$((missing + 1))
  fi
done

# Dev tools
echo ""
echo -e "${BOLD}Dev Tools${RESET}"
for entry in "${DEVTOOL_ENTRIES[@]}"; do
  local_name=$(get_field "$entry" 2)
  check_type=$(get_field "$entry" 4)
  check_value=$(get_field "$entry" 5)
  status=$(get_status_label "" "$check_type" "$check_value")
  if [[ "$status" == "installed" ]]; then
    echo -e "  ${CHECK} ${local_name}"
    installed=$((installed + 1))
  else
    echo -e "  ${CROSS} ${local_name} ${DIM}— not installed${RESET}"
    missing=$((missing + 1))
  fi
done

# VS Code extensions
echo ""
echo -e "${BOLD}VS Code Extensions${RESET}"
if is_vscode_installed; then
  for entry in "${EXT_ENTRIES[@]}"; do
    local_name=$(get_field "$entry" 2)
    ext_id=$(get_field "$entry" 3)
    if is_vscode_extension_installed "$ext_id"; then
      echo -e "  ${CHECK} ${local_name}"
      installed=$((installed + 1))
    else
      echo -e "  ${CROSS} ${local_name} ${DIM}— not installed${RESET}"
      missing=$((missing + 1))
    fi
  done
else
  echo -e "  ${SKIP} ${GRAY}VS Code not installed — skipping extension check${RESET}"
fi

# Summary
echo ""
echo -e "${WHITE}──────────────────────────────────${RESET}"
echo -e "  ${GREEN}Installed:${RESET} ${installed}"
echo -e "  ${RED}Missing:${RESET}   ${missing}"
echo ""

if [[ $missing -gt 0 ]]; then
  echo -e "  ${DIM}Run 'make install' to install missing items${RESET}"
  echo ""
fi
