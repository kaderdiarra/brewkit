#!/usr/bin/env bash
# UI functions — gum wrappers with automatic fallback to basic prompts

GUM_ACCENT="#FFFFFF"
GUM_SELECTED="#F5C542"

# ── Smart wrappers that auto-detect gum vs fallback ──

ui_choose() {
  local header="$1"
  shift
  if [[ "$USE_FALLBACK" == "true" ]]; then
    _fallback_choose "$header" "$@"
  else
    gum choose --header="$header" \
      --header.foreground="$GUM_ACCENT" \
      --cursor.foreground="$GUM_SELECTED" \
      --selected.foreground="$GUM_SELECTED" \
      "$@"
  fi
}

ui_choose_multi() {
  local header="$1"
  shift
  if [[ "$USE_FALLBACK" == "true" ]]; then
    _fallback_choose_multi "$header" "$@"
  else
    gum choose --no-limit \
      --header="$header" \
      --header.foreground="$GUM_ACCENT" \
      --cursor.foreground="$GUM_SELECTED" \
      --selected.foreground="$GUM_SELECTED" \
      "$@"
  fi
}

ui_choose_multi_preview() {
  local header="$1"
  shift
  if is_fzf_installed; then
    _fzf_choose_multi_preview "$header" "$@"
  else
    ui_choose_multi "$header" "$@"
  fi
}

ui_confirm() {
  local prompt="$1"
  if [[ "$USE_FALLBACK" == "true" ]]; then
    _fallback_confirm "$prompt"
  else
    gum confirm "$prompt" \
      --affirmative="Yes" \
      --negative="No" \
      --prompt.foreground="$GUM_ACCENT"
  fi
}

ui_input() {
  local placeholder="$1"
  local header="${2:-}"
  if [[ "$USE_FALLBACK" == "true" ]]; then
    _fallback_input "$placeholder" "$header"
  else
    if [[ -n "$header" ]]; then
      gum input --placeholder="$placeholder" \
        --header="$header" \
        --header.foreground="$GUM_ACCENT" \
        --cursor.foreground="$GUM_SELECTED"
    else
      gum input --placeholder="$placeholder" \
        --cursor.foreground="$GUM_SELECTED"
    fi
  fi
}

ui_spin() {
  local title="$1"
  shift
  if [[ "$USE_FALLBACK" == "true" ]]; then
    echo -e "  ${ARROW} ${title}"
    "$@"
  else
    gum spin --spinner dot \
      --title="$title" \
      --spinner.foreground="$GUM_ACCENT" \
      -- "$@"
  fi
}

ui_style_box() {
  local text="$1"
  if [[ "$USE_FALLBACK" == "true" ]]; then
    echo ""
    echo "  $text"
    echo ""
  else
    gum style \
      --border="rounded" \
      --border-foreground="$GUM_ACCENT" \
      --padding="0 2" \
      --margin="0 0" \
      "$text"
  fi
}

# ── Fallback functions (basic terminal prompts, no gum) ──

_fallback_confirm() {
  local prompt="$1"
  echo -e -n "  ${WHITE}${prompt}${RESET} [Y/n] "
  read -r answer
  [[ -z "$answer" || "$answer" =~ ^[Yy] ]]
}

_fallback_choose() {
  local header="$1"
  shift
  local options=("$@")
  echo ""
  echo -e "  ${WHITE}${header}${RESET}"
  local i=1
  for opt in "${options[@]}"; do
    echo -e "    ${WHITE}${i})${RESET} ${opt}"
    i=$((i + 1))
  done
  echo -n "  Enter number: "
  read -r choice
  if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#options[@]} ]]; then
    echo "${options[$((choice-1))]}"
  else
    echo "${options[0]}"
  fi
}

_fallback_choose_multi() {
  local header="$1"
  shift
  local options=("$@")
  echo ""
  echo -e "  ${WHITE}${header}${RESET}"
  echo -e "  ${DIM}Enter numbers separated by spaces (e.g., 1 3 5), or 'a' for all${RESET}"
  local i=1
  for opt in "${options[@]}"; do
    echo -e "    ${WHITE}${i})${RESET} ${opt}"
    i=$((i + 1))
  done
  echo -n "  Selection: "
  read -r choices

  if [[ "$choices" == "a" || "$choices" == "A" ]]; then
    printf '%s\n' "${options[@]}"
    return
  fi

  for num in $choices; do
    if [[ "$num" =~ ^[0-9]+$ ]] && [[ "$num" -ge 1 ]] && [[ "$num" -le ${#options[@]} ]]; then
      echo "${options[$((num-1))]}"
    fi
  done
}

_fallback_input() {
  local placeholder="$1"
  local header="${2:-}"
  if [[ -n "$header" ]]; then
    echo -e -n "  ${WHITE}${header}${RESET} [${DIM}${placeholder}${RESET}]: "
  else
    echo -e -n "  Input [${DIM}${placeholder}${RESET}]: "
  fi
  read -r value
  echo "$value"
}

# ── fzf functions (multi-select with inline preview) ──

# shellcheck disable=SC2016
_fzf_choose_multi_preview() {
  local header="$1"
  shift
  printf '%s\n' "$@" | fzf \
    --multi \
    --ansi \
    --reverse \
    --no-sort \
    --cycle \
    --highlight-line \
    --border=rounded \
    --border-label=" ${header} " \
    --border-label-pos=2 \
    --header='  tab=toggle  ctrl-a=all  ctrl-d=none  ?=preview  enter=confirm' \
    --header-first \
    --no-separator \
    --info=inline \
    --pointer='▌' \
    --marker='┃' \
    --preview="bash '${INSTALLER_ROOT}/installer/lib/preview.sh' {}" \
    --preview-window='right,45%,border-left,wrap,hidden,<80(down,40%,border-top,wrap,hidden)' \
    --preview-label=' Details ' \
    --bind='tab:toggle+down' \
    --bind='shift-tab:toggle+up' \
    --bind='ctrl-a:select-all' \
    --bind='ctrl-d:deselect-all' \
    --bind='ctrl-t:toggle-all' \
    --bind='?:toggle-preview' \
    --bind='start:change-footer: tab to select, enter to confirm' \
    --bind='multi:transform-footer:echo " $FZF_SELECT_COUNT item(s) selected"' \
    --footer-border=line \
    --color='header:dim,pointer:#f5c542,marker:#f5c542:bold,hl:#f5c542,hl+:#f5c542:bold,border:#666666,label:#ffffff:bold,preview-border:#444444'
}
