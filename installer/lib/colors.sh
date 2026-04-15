#!/usr/bin/env bash
# ANSI color constants and styled output helpers

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# 256-color constants
AMBER='\033[38;5;214m'
GOLD='\033[38;5;220m'
ORANGE='\033[38;5;208m'
SILVER='\033[38;5;250m'
ASH='\033[38;5;245m'
CHARCOAL='\033[38;5;240m'
SNOW='\033[38;5;255m'

# Symbols
CHECK="${GREEN}✓${RESET}"
CROSS="${RED}✗${RESET}"
ARROW="${WHITE}→${RESET}"
WARN="${YELLOW}⚠${RESET}"
INFO="${BLUE}ℹ${RESET}"
SKIP="${GRAY}○${RESET}"
UP="${MAGENTA}↑${RESET}"
GEAR="${WHITE}⚙${RESET}"

print_success() { echo -e "  ${CHECK} $1"; }
print_error()   { echo -e "  ${CROSS} $1"; }
print_info()    { echo -e "  ${INFO} $1"; }
print_warn()    { echo -e "  ${WARN} $1"; }
print_arrow()   { echo -e "  ${ARROW} $1"; }
print_skip()    { echo -e "  ${SKIP} ${GRAY}$1${RESET}"; }
print_upgrade() { echo -e "  ${UP} $1"; }

print_header() {
  echo ""
  echo -e "${BOLD}${WHITE}$1${RESET}"
  echo -e "${ASH}$(printf '%.0s─' $(seq 1 ${#1}))${RESET}"
}

print_step() {
  local step="$1"
  local total="$2"
  local label="$3"
  echo ""
  echo -e "${BOLD}${WHITE}[$step/$total]${RESET} ${BOLD}$label${RESET}"
  echo ""
}

# ── Gradient bar helper ──
_BAR_COLORS=(255 255 250 250 245 245 250 250 255 255 250 250 245 245 250 250 255 255 250 250 245 245 250 250 255 255 250 250 245 245)

_print_gradient_bar() {
  local animated="${1:-false}"
  local delay="${2:-0.015}"
  echo -ne "  "
  for c in "${_BAR_COLORS[@]}"; do
    echo -ne "\033[38;5;${c}m██${RESET}"
    if [[ "$animated" == "true" ]]; then
      sleep "$delay"
    fi
  done
  echo ""
}

# ── Animated banner ──
print_banner() {
  echo ""

  # Top gradient bar — animated
  _print_gradient_bar true 0.012

  # Logo — line by line with delay
  echo ""
  sleep 0.06
  echo -e "${WHITE}    ██████╗ ██████╗ ███████╗██╗    ██╗${RESET}${BOLD}${GOLD}██╗  ██╗██╗████████╗${RESET}"
  sleep 0.06
  echo -e "${WHITE}    ██╔══██╗██╔══██╗██╔════╝██║    ██║${RESET}${BOLD}${GOLD}██║ ██╔╝██║╚══██╔══╝${RESET}"
  sleep 0.06
  echo -e "${WHITE}    ██████╔╝██████╔╝█████╗  ██║ █╗ ██║${RESET}${AMBER}█████╔╝ ██║   ██║${RESET}"
  sleep 0.06
  echo -e "${SILVER}    ██╔══██╗██╔══██╗██╔══╝  ██║███╗██║${RESET}${ORANGE}██╔═██╗ ██║   ██║${RESET}"
  sleep 0.06
  echo -e "${ASH}    ██████╔╝██║  ██║███████╗╚███╔███╔╝${RESET}${ORANGE}██║  ██╗██║   ██║${RESET}"
  sleep 0.06
  echo -e "${CHARCOAL}    ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝   ╚═╝${RESET}"
  sleep 0.1

  # Tagline — centered
  echo ""
  echo -e "      ${AMBER}🍺${RESET} ${DIM}Your macOS dev environment, brewed fresh.${RESET}"
  sleep 0.06
  echo -e "       ${DIM}── interactive · idempotent · opinionated ──${RESET}"

  # Bottom gradient bar — animated
  echo ""
  _print_gradient_bar true 0.012
  echo ""
}

# ── Static banner (for non-interactive contexts) ──
print_banner_static() {
  echo ""
  _print_gradient_bar false
  echo ""
  echo -e "${WHITE}    ██████╗ ██████╗ ███████╗██╗    ██╗${RESET}${BOLD}${GOLD}██╗  ██╗██╗████████╗${RESET}"
  echo -e "${WHITE}    ██╔══██╗██╔══██╗██╔════╝██║    ██║${RESET}${BOLD}${GOLD}██║ ██╔╝██║╚══██╔══╝${RESET}"
  echo -e "${WHITE}    ██████╔╝██████╔╝█████╗  ██║ █╗ ██║${RESET}${AMBER}█████╔╝ ██║   ██║${RESET}"
  echo -e "${SILVER}    ██╔══██╗██╔══██╗██╔══╝  ██║███╗██║${RESET}${ORANGE}██╔═██╗ ██║   ██║${RESET}"
  echo -e "${ASH}    ██████╔╝██║  ██║███████╗╚███╔███╔╝${RESET}${ORANGE}██║  ██╗██║   ██║${RESET}"
  echo -e "${CHARCOAL}    ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝   ╚═╝${RESET}"
  echo ""
  echo -e "      ${AMBER}🍺${RESET} ${DIM}Your macOS dev environment, brewed fresh.${RESET}"
  echo -e "       ${DIM}── interactive · idempotent · opinionated ──${RESET}"
  echo ""
  _print_gradient_bar false
  echo ""
}
