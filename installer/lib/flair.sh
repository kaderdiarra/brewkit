#!/usr/bin/env bash
# Fun terminal flair — flavor text, timer, animations, tips

# ── Timer ──

INSTALL_START_TIME=""

start_timer() {
  INSTALL_START_TIME=$(date +%s)
}

get_elapsed() {
  if [[ -z "$INSTALL_START_TIME" ]]; then
    echo "0s"
    return
  fi
  local end_time
  end_time=$(date +%s)
  local elapsed=$((end_time - INSTALL_START_TIME))
  if [[ $elapsed -lt 60 ]]; then
    echo "${elapsed}s"
  elif [[ $elapsed -lt 3600 ]]; then
    local mins=$((elapsed / 60))
    local secs=$((elapsed % 60))
    echo "${mins}m ${secs}s"
  else
    local hours=$((elapsed / 3600))
    local mins=$(( (elapsed % 3600) / 60 ))
    echo "${hours}h ${mins}m"
  fi
}

# ── Flavor text for install progress ──

FLAVOR_TEXTS=(
  "Brewing"
  "Summoning"
  "Conjuring"
  "Unpacking"
  "Wiring up"
  "Deploying"
  "Spinning up"
  "Fetching"
  "Assembling"
  "Manifesting"
  "Forging"
  "Crafting"
)

# Counter files — initialized at source time so subshells inherit the path
_FLAVOR_COUNTER_FILE=$(mktemp /tmp/brewkit-flavor.XXXXXX)
echo "0" > "$_FLAVOR_COUNTER_FILE"

get_flavor_text() {
  local idx
  idx=$(cat "$_FLAVOR_COUNTER_FILE" 2>/dev/null || echo "0")
  local text="${FLAVOR_TEXTS[$idx]}"
  echo $(( (idx + 1) % ${#FLAVOR_TEXTS[@]} )) > "$_FLAVOR_COUNTER_FILE"
  echo "$text"
}

# ── Phase transition messages ──

PHASE_INTROS=(
  ""
  "Let's make sure you have the basics..."
  "Time to pick your weapons."
  ""
  "Checking what's already on your machine..."
  "Grab a coffee, this might take a minute."
  "Almost there — final touches."
)

print_phase_intro() {
  local phase="$1"
  local msg="${PHASE_INTROS[$phase]}"
  if [[ -n "$msg" ]]; then
    echo -e "  ${DIM}${msg}${RESET}"
    echo ""
  fi
}

# ── Dev tips (shown during install phase) ──

DEV_TIPS=(
  "Tip: Use 'cmd+,' to open settings in most macOS apps"
  "Tip: 'cmd+shift+.' shows hidden files in Finder"
  "Tip: Three-finger drag is under Accessibility → Pointer Control"
  "Tip: Rectangle's shortcuts: ctrl+opt+arrow keys for window snapping"
  "Tip: 'defaults read' shows current macOS settings for any domain"
  "Tip: Raycast can replace Spotlight, calculator, clipboard history, and more"
  "Tip: 'brew cleanup' frees up disk space from old formula versions"
  "Tip: 'nvm alias default node' makes your current version persistent"
  "Tip: 'cmd+k' clears terminal — even in VS Code's integrated terminal"
  "Tip: AltTab can show window previews, just like Windows alt-tab"
  "Tip: iTerm2's hotkey window (opt+space) is a game changer"
  "Tip: 'git stash' is your friend — stash changes without committing"
)

_TIP_COUNTER_FILE=$(mktemp /tmp/brewkit-tip.XXXXXX)
_TIP_TIME_FILE=$(mktemp /tmp/brewkit-tiptime.XXXXXX)
echo "0" > "$_TIP_COUNTER_FILE"
date +%s > "$_TIP_TIME_FILE"

maybe_show_tip() {
  local now last_time
  now=$(date +%s)
  last_time=$(cat "$_TIP_TIME_FILE" 2>/dev/null || echo "0")
  # Show a tip every ~15 seconds
  if [[ $(( now - last_time )) -ge 15 ]]; then
    echo "$now" > "$_TIP_TIME_FILE"
    local idx
    idx=$(cat "$_TIP_COUNTER_FILE" 2>/dev/null || echo "0")
    local tip="${DEV_TIPS[$idx]}"
    echo $(( (idx + 1) % ${#DEV_TIPS[@]} )) > "$_TIP_COUNTER_FILE"
    echo ""
    echo -e "  ${DIM}  ${tip}${RESET}"
    echo ""
  fi
}

# ── Completion messages based on results ──

get_completion_message() {
  local success_count="${1:-0}"
  local failed_count="${2:-0}"
  local elapsed
  elapsed=$(get_elapsed)

  if [[ $failed_count -eq 0 && $success_count -gt 0 ]]; then
    # Perfect run
    local perfect_msgs=(
      "⚡ Brewed to perfection in ${elapsed}"
      "✦ Freshly configured in ${elapsed}"
      "◆ Crafted with care in ${elapsed}"
      "▸ All systems go — ${elapsed}"
      "⬡ Setup locked in ${elapsed}"
    )
    local idx=$(( RANDOM % ${#perfect_msgs[@]} ))
    echo "${perfect_msgs[$idx]}"
  elif [[ $failed_count -gt 0 && $success_count -gt 0 ]]; then
    # Partial success
    echo "◇ Done in ${elapsed} — ${failed_count} item(s) need attention"
  elif [[ $success_count -eq 0 && $failed_count -eq 0 ]]; then
    # Nothing to do
    echo "○ Already good to go — ${elapsed}"
  else
    # All failed
    echo "◈ Finished in ${elapsed} — check logs for issues"
  fi
}

# ── Animated completion banner ──

print_completion_banner() {
  local success_count="${1:-0}"
  local failed_count="${2:-0}"

  echo ""
  _print_gradient_bar true 0.01
  echo ""

  if [[ $failed_count -eq 0 ]]; then
    echo -e "            ${BOLD}${WHITE}✓  Setup Complete${RESET}"
  else
    echo -e "            ${BOLD}${WHITE}⚠  Setup Complete${RESET}"
  fi

  local msg
  msg=$(get_completion_message "$success_count" "$failed_count")
  echo -e "            ${DIM}${msg}${RESET}"

  echo ""
  _print_gradient_bar true 0.01
  echo ""
}

# ── Witty loading dots ──
# Usage: start_loading "message" & PID=$!; do_work; stop_loading $PID

LOADING_MESSAGES=(
  "Talking to the brew oracle"
  "Convincing your Mac"
  "Negotiating with package managers"
  "Reticulating splines"
  "Warming up the compiler"
  "Consulting Stack Overflow"
  "Downloading more RAM"
)

get_loading_message() {
  local idx=$(( RANDOM % ${#LOADING_MESSAGES[@]} ))
  echo "${LOADING_MESSAGES[$idx]}"
}

# Clean up temp files — called from log.sh cleanup trap
cleanup_flair() {
  rm -f "$_FLAVOR_COUNTER_FILE" "$_TIP_COUNTER_FILE" "$_TIP_TIME_FILE" 2>/dev/null
}
