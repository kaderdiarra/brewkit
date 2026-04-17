#!/usr/bin/env bash
# Brewkit — tool info browser
# Usage: bash installer/info.sh [tool_name]
#   No args    → browse all tools by category
#   tool_name  → show detailed info for a specific tool

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source dependencies
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/registry/apps.sh"
source "${SCRIPT_DIR}/registry/dev-tools.sh"
source "${SCRIPT_DIR}/registry/editor.sh"
source "${SCRIPT_DIR}/lib/checks.sh"

# ── Helpers ──

get_ext_url() {
  local ext_id="$1"
  local custom_url="$2"
  if [[ -n "$custom_url" ]]; then
    echo "$custom_url"
  else
    echo "https://marketplace.visualstudio.com/items?itemName=${ext_id}"
  fi
}

get_install_cmd() {
  local entry="$1"
  local type="$2"

  case "$type" in
    app)
      local brew_args
      brew_args=$(get_field "$entry" 3)
      echo "brew install ${brew_args}"
      ;;
    devtool)
      local method
      method=$(get_field "$entry" 3)
      local method_type="${method%%:*}"
      local method_value="${method#*:}"
      case "$method_type" in
        brew) echo "brew install ${method_value}" ;;
        cask) echo "brew install --cask ${method_value}" ;;
        custom) echo "custom installer (${method_value})" ;;
      esac
      ;;
    ext)
      local ext_id
      ext_id=$(get_field "$entry" 3)
      echo "code --install-extension ${ext_id}"
      ;;
  esac
}

get_status_icon() {
  local entry="$1"
  local type="$2"

  case "$type" in
    app)
      local check_type check_value
      check_type=$(get_field "$entry" 4)
      check_value=$(get_field "$entry" 5)
      local status
      status=$(get_status_label "" "$check_type" "$check_value")
      if [[ "$status" == "installed" ]]; then
        echo -e "${GREEN}● installed${RESET}"
      else
        echo -e "${DIM}○ not installed${RESET}"
      fi
      ;;
    devtool)
      local check_type check_value
      check_type=$(get_field "$entry" 4)
      check_value=$(get_field "$entry" 5)
      local status
      status=$(get_status_label "" "$check_type" "$check_value")
      if [[ "$status" == "installed" ]]; then
        echo -e "${GREEN}● installed${RESET}"
      else
        echo -e "${DIM}○ not installed${RESET}"
      fi
      ;;
    ext)
      local ext_id
      ext_id=$(get_field "$entry" 3)
      if is_vscode_extension_installed "$ext_id"; then
        echo -e "${GREEN}● installed${RESET}"
      else
        echo -e "${DIM}○ not installed${RESET}"
      fi
      ;;
  esac
}

# ── Show detail for a single tool ──

show_tool_detail() {
  local search="$1"
  local search_lower
  search_lower=$(echo "$search" | tr '[:upper:]' '[:lower:]')

  local found=false

  # Search apps
  for entry in "${APP_ENTRIES[@]}"; do
    local key name
    key=$(get_field "$entry" 1)
    name=$(get_field "$entry" 2)
    local name_lower
    name_lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    if [[ "$key" == "$search_lower" || "$name_lower" == "$search_lower" ]]; then
      local desc url
      desc=$(get_field "$entry" 6)
      url=$(get_field "$entry" 7)
      echo ""
      echo -e "  ${BOLD}${WHITE}${name}${RESET}  ${DIM}(app)${RESET}"
      echo -e "  ${desc}"
      echo ""
      echo -e "  ${DIM}Status:${RESET}  $(get_status_icon "$entry" "app")"
      echo -e "  ${DIM}Install:${RESET} $(get_install_cmd "$entry" "app")"
      [[ -n "$url" ]] && echo -e "  ${DIM}URL:${RESET}     ${CYAN}${url}${RESET}"
      echo ""
      found=true
      return
    fi
  done

  # Search dev tools
  for entry in "${DEVTOOL_ENTRIES[@]}"; do
    local key name
    key=$(get_field "$entry" 1)
    name=$(get_field "$entry" 2)
    local name_lower
    name_lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    if [[ "$key" == "$search_lower" || "$name_lower" == "$search_lower" ]]; then
      local desc url
      desc=$(get_field "$entry" 6)
      url=$(get_field "$entry" 7)
      echo ""
      echo -e "  ${BOLD}${WHITE}${name}${RESET}  ${DIM}(dev tool)${RESET}"
      echo -e "  ${desc}"
      echo ""
      echo -e "  ${DIM}Status:${RESET}  $(get_status_icon "$entry" "devtool")"
      echo -e "  ${DIM}Install:${RESET} $(get_install_cmd "$entry" "devtool")"
      [[ -n "$url" ]] && echo -e "  ${DIM}URL:${RESET}     ${CYAN}${url}${RESET}"
      echo ""
      found=true
      return
    fi
  done

  # Search extensions
  for entry in "${EXT_ENTRIES[@]}"; do
    local key name
    key=$(get_field "$entry" 1)
    name=$(get_field "$entry" 2)
    local name_lower
    name_lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    if [[ "$key" == "$search_lower" || "$name_lower" == "$search_lower" ]]; then
      local desc cat ext_id url
      desc=$(get_field "$entry" 4)
      cat=$(get_field "$entry" 5)
      ext_id=$(get_field "$entry" 3)
      url=$(get_ext_url "$ext_id" "$(get_field "$entry" 6)")
      echo ""
      echo -e "  ${BOLD}${WHITE}${name}${RESET}  ${DIM}(extension · ${cat})${RESET}"
      echo -e "  ${desc}"
      echo ""
      echo -e "  ${DIM}Status:${RESET}  $(get_status_icon "$entry" "ext")"
      echo -e "  ${DIM}Install:${RESET} $(get_install_cmd "$entry" "ext")"
      echo -e "  ${DIM}ID:${RESET}      ${ext_id}"
      echo -e "  ${DIM}URL:${RESET}     ${CYAN}${url}${RESET}"
      echo ""
      found=true
      return
    fi
  done

  if [[ "$found" == "false" ]]; then
    echo ""
    echo -e "  ${CROSS} No tool found matching '${search}'"
    echo -e "  ${DIM}Run 'make info' to see all available tools${RESET}"
    echo ""
    exit 1
  fi
}

# ── Browse all tools ──

browse_all() {
  print_banner_static

  # Pre-cache install status
  echo -ne "  ${ARROW} Loading install status..."
  cache_brew_lists
  cache_vscode_extensions
  echo -e "\r\033[K  ${CHECK} Install status loaded"
  echo ""

  # Apps
  echo -e "  ${BOLD}${WHITE}Apps${RESET}  ${DIM}(${#APP_ENTRIES[@]} available)${RESET}"
  echo -e "  ${ASH}$(printf '%.0s─' $(seq 1 40))${RESET}"
  for entry in "${APP_ENTRIES[@]}"; do
    local name desc url
    name=$(get_field "$entry" 2)
    desc=$(get_field "$entry" 6)
    url=$(get_field "$entry" 7)
    local status_icon
    status_icon=$(get_status_icon "$entry" "app")
    if [[ -n "$url" ]]; then
      printf "  ${status_icon}  %-16s ${DIM}%s${RESET}\n" "$name" "$desc"
    else
      printf "  ${status_icon}  %-16s ${DIM}%s${RESET}\n" "$name" "$desc"
    fi
  done

  echo ""

  # Dev Tools
  echo -e "  ${BOLD}${WHITE}Dev Tools${RESET}  ${DIM}(${#DEVTOOL_ENTRIES[@]} available)${RESET}"
  echo -e "  ${ASH}$(printf '%.0s─' $(seq 1 40))${RESET}"
  for entry in "${DEVTOOL_ENTRIES[@]}"; do
    local name desc
    name=$(get_field "$entry" 2)
    desc=$(get_field "$entry" 6)
    local status_icon
    status_icon=$(get_status_icon "$entry" "devtool")
    printf "  ${status_icon}  %-16s ${DIM}%s${RESET}\n" "$name" "$desc"
  done

  echo ""

  # Extensions by category
  echo -e "  ${BOLD}${WHITE}VS Code Extensions${RESET}  ${DIM}(${#EXT_ENTRIES[@]} available)${RESET}"
  echo -e "  ${ASH}$(printf '%.0s─' $(seq 1 40))${RESET}"
  local current_cat=""
  for entry in "${EXT_ENTRIES[@]}"; do
    local name desc cat
    name=$(get_field "$entry" 2)
    desc=$(get_field "$entry" 4)
    cat=$(get_field "$entry" 5)

    if [[ "$cat" != "$current_cat" ]]; then
      local cat_label
      cat_label=$(echo "$cat" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
      echo ""
      echo -e "    ${WHITE}${cat_label}${RESET}"
      current_cat="$cat"
    fi

    local status_icon
    status_icon=$(get_status_icon "$entry" "ext")
    printf "    ${status_icon}  %-24s ${DIM}%s${RESET}\n" "$name" "$desc"
  done

  echo ""
  echo -e "  ${DIM}Run 'make info <tool>' for details on any tool${RESET}"
  echo ""
}

# ── Interactive browse with gum ──

browse_interactive() {
  # Build a list of all tools for gum filter
  local items=()
  for entry in "${APP_ENTRIES[@]}"; do
    local name desc
    name=$(get_field "$entry" 2)
    desc=$(get_field "$entry" 6)
    items+=("$(printf '%-20s  %s  [app]' "$name" "$desc")")
  done
  for entry in "${DEVTOOL_ENTRIES[@]}"; do
    local name desc
    name=$(get_field "$entry" 2)
    desc=$(get_field "$entry" 6)
    items+=("$(printf '%-20s  %s  [dev tool]' "$name" "$desc")")
  done
  for entry in "${EXT_ENTRIES[@]}"; do
    local name desc cat
    name=$(get_field "$entry" 2)
    desc=$(get_field "$entry" 4)
    cat=$(get_field "$entry" 5)
    items+=("$(printf '%-20s  %s  [%s]' "$name" "$desc" "$cat")")
  done

  local selected
  selected=$(printf '%s\n' "${items[@]}" | gum filter \
    --header="Search tools (type to filter, enter to select):" \
    --header.foreground="#FFFFFF" \
    --indicator.foreground="#F5C542" \
    --match.foreground="#F5C542" \
    --height=20 \
    --placeholder="Type a tool name...")

  if [[ -n "$selected" ]]; then
    local tool_name
    tool_name=$(echo "$selected" | awk '{print $1}')
    show_tool_detail "$tool_name"
  fi
}

# ── Main ──

if [[ $# -gt 0 ]]; then
  if [[ "$1" == "browse" ]]; then
    if command -v gum &>/dev/null && [[ -t 0 ]]; then
      browse_interactive
    else
      browse_all
    fi
  else
    show_tool_detail "$1"
  fi
else
  browse_all
fi
