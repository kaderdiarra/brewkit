#!/usr/bin/env bash
# Pull latest Brewkit config and optionally re-run the installer

set -eo pipefail

INSTALLER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${INSTALLER_ROOT}/installer/lib/colors.sh"

echo ""
echo -e "${BOLD}${WHITE}Brewkit — Update${RESET}"
echo -e "${ASH}────────────────${RESET}"
echo ""

# Check for uncommitted changes
if ! git -C "$INSTALLER_ROOT" diff --quiet 2>/dev/null || ! git -C "$INSTALLER_ROOT" diff --cached --quiet 2>/dev/null; then
  echo -e "  ${WARN} You have local changes. Stash or commit them first."
  echo ""
  exit 1
fi

# Check current branch
current_branch=$(git -C "$INSTALLER_ROOT" branch --show-current 2>/dev/null)
if [[ "$current_branch" != "main" ]]; then
  echo -e "  ${WARN} Not on main branch (currently on ${BOLD}${current_branch}${RESET}). Switch to main first."
  echo ""
  exit 1
fi

# Fetch and check for updates
echo -e "  ${ARROW} Checking for updates..."
git -C "$INSTALLER_ROOT" fetch origin main --quiet 2>/dev/null

local_hash=$(git -C "$INSTALLER_ROOT" rev-parse HEAD)
remote_hash=$(git -C "$INSTALLER_ROOT" rev-parse origin/main)

if [[ "$local_hash" == "$remote_hash" ]]; then
  echo -e "  ${CHECK} Already up to date."
  echo ""
  exit 0
fi

# Show what's new
commit_count=$(git -C "$INSTALLER_ROOT" rev-list HEAD..origin/main --count)
echo -e "  ${INFO} ${BOLD}${commit_count}${RESET} new commit(s) available"
echo ""
git -C "$INSTALLER_ROOT" log HEAD..origin/main --oneline --no-decorate | while read -r line; do
  echo -e "    ${DIM}${line}${RESET}"
done
echo ""

# Confirm
echo -e -n "  ${WHITE}Pull latest changes?${RESET} [Y/n] "
read -r answer
if [[ -n "$answer" && ! "$answer" =~ ^[Yy] ]]; then
  echo -e "  ${SKIP} ${GRAY}Update cancelled.${RESET}"
  echo ""
  exit 0
fi

# Pull
echo ""
echo -e "  ${ARROW} Pulling..."
if git -C "$INSTALLER_ROOT" pull --ff-only origin main --quiet 2>/dev/null; then
  echo -e "  ${CHECK} Updated to latest."
else
  echo -e "  ${CROSS} Pull failed. Try manually: git pull origin main"
  echo ""
  exit 1
fi

# Offer to re-run installer
echo ""
echo -e -n "  ${WHITE}Re-run installer to apply new config?${RESET} [y/N] "
read -r run_answer
if [[ "$run_answer" =~ ^[Yy] ]]; then
  echo ""
  exec bash "${INSTALLER_ROOT}/install.sh"
else
  echo ""
  echo -e "  ${DIM}Run 'make install' when you're ready.${RESET}"
  echo ""
fi
