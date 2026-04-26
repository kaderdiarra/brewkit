#!/usr/bin/env bash
# Shell configuration — aliases and plugin definitions

# Alias groups — pipe-delimited: "alias_name|command"
GIT_ALIAS_ENTRIES=(
  "ga|git add"
  "gaa|git add ."
  "gcm|git commit -m"
  "gpsh|git push"
  "gpsho|git push -u origin"
  "gpl|git pull"
  "gs|git status"
  "gss|git status -s"
  "glog|git log --oneline --graph --decorate"
  "gb|git branch"
  "gco|git checkout"
  "gcb|git checkout -b"
  "gd|git diff"
  "gsw|git switch"
  "gswc|git switch -c"
  "gst|git stash"
  "gstp|git stash pop"
)

GENERAL_ALIAS_ENTRIES=(
  "c|clear"
  "o|open ."
  "ll|ls -alF"
  "la|ls -A"
  "l|ls -CF"
  "sz|source ~/.zshrc"
  "..|cd .."
  "...|cd ../.."
)

DOCKER_ALIAS_ENTRIES=(
  "d|docker"
  "dps|docker ps"
  "dc|docker compose"
  "dcu|docker compose up"
  "dcd|docker compose down"
  "dcud|docker compose up -d"
)

PNPM_ALIAS_ENTRIES=(
  "p|pnpm"
  "pi|pnpm install"
  "pa|pnpm add"
  "pd|pnpm dev"
  "pb|pnpm build"
  "pr|pnpm run"
)

# Generate alias block from entries
generate_alias_block() {
  local header="$1"
  shift
  local entries=("$@")
  local block=""
  block="# ${header}"$'\n'
  for entry in "${entries[@]}"; do
    local alias_name="${entry%%|*}"
    local alias_cmd="${entry#*|}"
    block+="alias ${alias_name}='${alias_cmd}'"$'\n'
  done
  echo "$block"
}

# Generate the `aliases` cheatsheet function based on selected groups
# Outputs a self-contained zsh function with alias data baked in
generate_aliases_function() {
  local selected_groups=("$@")
  local func=""
  local available_groups="${selected_groups[*]}"

  func+='# Brewkit alias cheatsheet — run `aliases` or `aliases <group>`'$'\n'
  func+='aliases() {'$'\n'
  func+='  local group="${1:-all}"'$'\n'
  func+='  local bold="\033[1m" dim="\033[2m" reset="\033[0m" cyan="\033[36m"'$'\n'
  func+='  _ah() { echo ""; echo -e "  ${bold}$1${reset}"; echo "  ────────────────────"; }'$'\n'
  func+='  _ar() { printf "  \033[36m%-8s\033[0m \033[2m%s\033[0m\n" "$1" "$2"; }'$'\n'
  func+='  case "$group" in'$'\n'

  # Generate each group case + its rows
  for group in "${selected_groups[@]}"; do
    local label=""
    case "$group" in
      git)     label="Git" ;;
      general) label="General" ;;
      docker)  label="Docker" ;;
      pnpm)    label="pnpm" ;;
    esac

    func+="    ${group})"$'\n'
    func+="      _ah \"${label}\""$'\n'
    _generate_rows_for_group "$group" func
    func+='      ;;'$'\n'
  done

  # "all" case
  func+='    all)'$'\n'
  for group in "${selected_groups[@]}"; do
    local label=""
    case "$group" in
      git)     label="Git" ;;
      general) label="General" ;;
      docker)  label="Docker" ;;
      pnpm)    label="pnpm" ;;
    esac
    func+="      _ah \"${label}\""$'\n'
    _generate_rows_for_group "$group" func
  done
  func+='      ;;'$'\n'

  # "help" case
  func+='    help|--help|-h)'$'\n'
  func+='      echo ""'$'\n'
  func+='      echo -e "  ${bold}aliases${reset} — Brewkit shell alias cheatsheet"'$'\n'
  func+='      echo ""'$'\n'
  func+='      echo -e "  ${bold}Usage:${reset}"'$'\n'
  func+='      echo "    aliases            Show all aliases"'$'\n'
  func+='      echo "    aliases <group>    Show aliases for a specific group"'$'\n'
  func+='      echo "    aliases help       Show this help"'$'\n'
  func+='      echo ""'$'\n'
  func+='      echo -e "  ${bold}Available groups:${reset}"'$'\n'
  for group in "${selected_groups[@]}"; do
    local label=""
    case "$group" in
      git)     label="Git shortcuts (ga, gcm, gpsh...)" ;;
      general) label="General shell (c, ll, .., sz...)" ;;
      docker)  label="Docker commands (d, dc, dcu...)" ;;
      pnpm)    label="pnpm commands (p, pi, pd...)" ;;
    esac
    func+="      printf \"    ${cyan}%-14s${reset} ${dim}${label}${reset}\n\" \"${group}\""$'\n'
  done
  func+='      ;;'$'\n'

  # Unknown
  func+='    *)'$'\n'
  func+="      echo \"Unknown group: \$group. Run 'aliases help' for usage.\""$'\n'
  func+='      ;;'$'\n'
  func+='  esac'$'\n'
  func+='  echo ""'$'\n'
  func+='}'$'\n'

  echo "$func"
}

# Helper: append _ar rows to a variable for a given group
_generate_rows_for_group() {
  local group="$1"
  local varname="$2"
  local entries=()

  case "$group" in
    git)     entries=("${GIT_ALIAS_ENTRIES[@]}") ;;
    general) entries=("${GENERAL_ALIAS_ENTRIES[@]}") ;;
    docker)  entries=("${DOCKER_ALIAS_ENTRIES[@]}") ;;
    pnpm)    entries=("${PNPM_ALIAS_ENTRIES[@]}") ;;
  esac

  for entry in "${entries[@]}"; do
    local alias_name="${entry%%|*}"
    local alias_cmd="${entry#*|}"
    eval "${varname}+='      _ar \"${alias_name}\" \"${alias_cmd}\"'\$'\\n'"
  done
}

# ─── Shortcut cheatsheet entries ─────────────────────────────────────────────
# Pipe-delimited: "shortcut|description"
# Note: ⌘=Cmd ⌥=Option ⌃=Ctrl ⇧=Shift — displayed as-is for Mac readability

VSCODE_SHORTCUT_ENTRIES=(
  "⌥ 1/2/3|Focus editor group 1/2/3"
  "⌘⌥ ←/→|Move editor to left/right group"
  "⌘⌥ Backtick|Split terminal"
  "⌃⇧ ↑/↓|Move line up/down"
  "⌃⇧ D|Duplicate selection"
  "⌘⌥ O|Organize imports"
  "⌘⌥ E|Focus sidebar"
  "⌘⌥ B|Toggle activity bar"
  "⌘⌥ M|Zen mode"
  "⌘⌥ W|Close other editors"
  "⌘⌥⇧ J|Maximize panel"
  "⌘⌥ P|Open recent project"
  "⌘ P|Quick open file"
  "⇧⌘ P|Command palette"
  "⌘ D|Select next occurrence"
  "⇧⌘ L|Select all occurrences"
  "⌥⌘ ↑/↓|Add cursor above/below"
  "⌘ /|Toggle line comment"
  "⌥ ↑/↓|Move line up/down"
  "⇧⌥ ↑/↓|Copy line up/down"
  "⌘ B|Toggle sidebar"
  "⌃ Backtick|Toggle terminal"
  "F2|Rename symbol"
  "F12|Go to definition"
  "⇧ F12|Show references"
  "⌘ .|Quick fix"
)

RAYCAST_SHORTCUT_ENTRIES=(
  "⌘ Space|Open Raycast (replaces Spotlight)"
  "⌘⇧ Space|Clipboard history (if configured)"
  "Tab|Show actions for selected item"
  "⌘ K|Show all actions"
  "⌘ ,|Open Raycast settings"
  "⌘ ⏎|Open in background"
  "⌥ ⏎|Run quicklink / action"
  "⌘ L|Copy text to Raycast"
  "⌘ ⇧ H|Toggle floating notes"
  "Type :|Search snippets"
  "Type >|Run script command"
)

RECTANGLE_SHORTCUT_ENTRIES=(
  "⌃⌥ ←|Left half"
  "⌃⌥ →|Right half"
  "⌃⌥ ↑|Top half"
  "⌃⌥ ↓|Bottom half"
  "⌃⌥ ⏎|Maximize"
  "⌃⌥ C|Center window"
  "⌃⌥⇧ ←|Left two-thirds"
  "⌃⌥⇧ →|Right two-thirds"
)

AEROSPACE_SHORTCUT_ENTRIES=(
  "⌥ H/L/K/J|Focus left/right/up/down"
  "⌥⇧ H/L/K/J|Move window left/right/up/down"
  "⌥ 1-9|Switch to workspace 1-9"
  "⌥⇧ 1-9|Move window to workspace 1-9"
  "⌥⇧ F|Toggle float"
  "⌥⇧ -/=|Resize -/+"
  "⌥ /|Toggle split direction"
  "⌥ ,|Toggle layout (tiles/accordion)"
  "⌥⇧ ⏎|Toggle fullscreen"
)

MACOS_SHORTCUT_ENTRIES=(
  "⌘ Space|Spotlight (or Raycast)"
  "⌘ Tab|Switch apps"
  "⌘ Backtick|Switch windows of same app"
  "⌃ ↑|Mission Control"
  "⌃ ↓|App Expose"
  "⌃ ←/→|Switch desktop/space"
  "⌘⇧ 3|Screenshot full screen"
  "⌘⇧ 4|Screenshot selection"
  "⌘⇧ 5|Screenshot/recording toolbar"
  "⌘ H|Hide app"
  "⌘⌥ H|Hide all other apps"
  "⌘ Q|Quit app"
  "⌘ W|Close window/tab"
  "⌃ F2|Focus menu bar"
)

ARC_SHORTCUT_ENTRIES=(
  "⌘ T|New tab"
  "⌘ L|Focus address bar"
  "⌘ ⇧ C|Copy URL"
  "⌘ D|Add bookmark"
  "⌘ S|Toggle sidebar"
  "⌘ ⌥ N|New little arc window"
  "⌃ Tab|Next tab"
  "⌃⇧ Tab|Previous tab"
  "⌘ 1-9|Switch to tab 1-9"
  "⌘ ⇧ D|Split view"
)

ITERM2_SHORTCUT_ENTRIES=(
  "⌘ D|Split pane right"
  "⌘⇧ D|Split pane below"
  "⌘ ⌥ ←/→|Switch pane"
  "⌘ T|New tab"
  "⌘ W|Close tab/pane"
  "⌘ ←/→|Switch tab"
  "⌘ ⏎|Toggle fullscreen"
  "⌘ K|Clear buffer"
  "⌘ F|Find"
  "⌘ ;|Autocomplete"
)

VIM_SHORTCUT_ENTRIES=(
  "h/j/k/l|Move left/down/up/right"
  "w/b|Next/previous word"
  "0 / \$|Start/end of line"
  "gg / G|Start/end of file"
  "i / a|Insert before/after cursor"
  "o / O|New line below/above"
  "dd / yy / p|Delete/yank/paste line"
  "ciw / diw|Change/delete inner word"
  "ci + quote/paren|Change inside quotes/parens"
  "v / V / Ctrl-V|Visual / line / block mode"
  "/ + pattern|Search forward"
  "u / Ctrl-R|Undo / redo"
  ":w / :q / :wq|Save / quit / save+quit"
)

# Generate the `keys` cheatsheet function based on installed tools
# Outputs a self-contained zsh function written to .zshrc
generate_keys_function() {
  local selected_tools=("$@")
  local func=""

  func+='# Brewkit keys cheatsheet — run `keys` or `keys <tool>`'$'\n'
  func+='keys() {'$'\n'
  func+='  local tool="${1:-all}"'$'\n'
  func+='  local bold="\033[1m" dim="\033[2m" reset="\033[0m" cyan="\033[36m" yellow="\033[33m"'$'\n'
  func+='  _sh() { echo ""; echo -e "  ${bold}${yellow}$1${reset}"; echo "  ────────────────────────────"; }'$'\n'
  func+='  _sr() { printf "  \033[36m%-18s\033[0m \033[2m%s\033[0m\n" "$1" "$2"; }'$'\n'
  func+='  case "$tool" in'$'\n'

  for tool in "${selected_tools[@]}"; do
    local label=""
    case "$tool" in
      vscode)    label="VS Code / Cursor" ;;
      raycast)   label="Raycast" ;;
      rectangle) label="Rectangle" ;;
      aerospace) label="AeroSpace" ;;
      macos)     label="macOS" ;;
      arc)       label="Arc Browser" ;;
      iterm2)    label="iTerm2" ;;
      vim)       label="Vim (Essential)" ;;
    esac

    func+="    ${tool})"$'\n'
    func+="      _sh \"${label}\""$'\n'
    _generate_key_rows "$tool" func
    func+='      ;;'$'\n'
  done

  # "all" case
  func+='    all)'$'\n'
  for tool in "${selected_tools[@]}"; do
    local label=""
    case "$tool" in
      vscode)    label="VS Code / Cursor" ;;
      raycast)   label="Raycast" ;;
      rectangle) label="Rectangle" ;;
      aerospace) label="AeroSpace" ;;
      macos)     label="macOS" ;;
      arc)       label="Arc Browser" ;;
      iterm2)    label="iTerm2" ;;
      vim)       label="Vim (Essential)" ;;
    esac
    func+="      _sh \"${label}\""$'\n'
    _generate_key_rows "$tool" func
  done
  func+='      ;;'$'\n'

  # "list" case — show available tools
  func+='    list)'$'\n'
  func+='      echo ""'$'\n'
  func+='      echo -e "  ${bold}Available tools:${reset}"'$'\n'
  for tool in "${selected_tools[@]}"; do
    func+="      echo \"    ${tool}\""$'\n'
  done
  func+='      ;;'$'\n'

  # "help" case
  func+='    help|--help|-h)'$'\n'
  func+='      echo ""'$'\n'
  func+='      echo -e "  ${bold}keys${reset} — Brewkit keyboard shortcuts cheatsheet"'$'\n'
  func+='      echo ""'$'\n'
  func+='      echo -e "  ${bold}Usage:${reset}"'$'\n'
  func+='      echo "    keys              Show all shortcuts"'$'\n'
  func+='      echo "    keys <tool>       Show shortcuts for a specific tool"'$'\n'
  func+='      echo "    keys list         List available tools"'$'\n'
  func+='      echo "    keys help         Show this help"'$'\n'
  func+='      echo ""'$'\n'
  func+='      echo -e "  ${bold}Available tools:${reset}"'$'\n'
  for tool in "${selected_tools[@]}"; do
    local label=""
    case "$tool" in
      vscode)    label="VS Code / Cursor" ;;
      raycast)   label="Raycast" ;;
      rectangle) label="Rectangle" ;;
      aerospace) label="AeroSpace" ;;
      macos)     label="macOS" ;;
      arc)       label="Arc Browser" ;;
      iterm2)    label="iTerm2" ;;
      vim)       label="Vim (Essential)" ;;
    esac
    func+="      printf \"    ${cyan}%-14s${reset} ${dim}${label}${reset}\n\" \"${tool}\""$'\n'
  done
  func+='      ;;'$'\n'

  # Unknown
  func+='    *)'$'\n'
  func+="      echo \"Unknown tool: \$tool. Run 'keys help' for usage.\""$'\n'
  func+='      ;;'$'\n'
  func+='  esac'$'\n'
  func+='  echo ""'$'\n'
  func+='}'$'\n'

  echo "$func"
}

# Helper: append _sr rows to a variable for a given tool
_generate_key_rows() {
  local tool="$1"
  local varname="$2"
  local entries=()

  case "$tool" in
    vscode)    entries=("${VSCODE_SHORTCUT_ENTRIES[@]}") ;;
    raycast)   entries=("${RAYCAST_SHORTCUT_ENTRIES[@]}") ;;
    rectangle) entries=("${RECTANGLE_SHORTCUT_ENTRIES[@]}") ;;
    aerospace) entries=("${AEROSPACE_SHORTCUT_ENTRIES[@]}") ;;
    macos)     entries=("${MACOS_SHORTCUT_ENTRIES[@]}") ;;
    arc)       entries=("${ARC_SHORTCUT_ENTRIES[@]}") ;;
    iterm2)    entries=("${ITERM2_SHORTCUT_ENTRIES[@]}") ;;
    vim)       entries=("${VIM_SHORTCUT_ENTRIES[@]}") ;;
  esac

  for entry in "${entries[@]}"; do
    local shortcut="${entry%%|*}"
    local desc="${entry#*|}"
    eval "${varname}+='      _sr \"${shortcut}\" \"${desc}\"'\$'\\n'"
  done
}

# Oh My Zsh plugins
OMZ_BUILTIN_PLUGINS="git docker node npm z"
OMZ_CUSTOM_PLUGINS="zsh-autosuggestions zsh-syntax-highlighting"

OMZ_CUSTOM_PLUGIN_REPOS_KEYS=(zsh-autosuggestions zsh-syntax-highlighting)
OMZ_CUSTOM_PLUGIN_REPOS_URLS=(
  "https://github.com/zsh-users/zsh-autosuggestions"
  "https://github.com/zsh-users/zsh-syntax-highlighting"
)

install_omz_custom_plugins() {
  local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
  local i=0
  for plugin in "${OMZ_CUSTOM_PLUGIN_REPOS_KEYS[@]}"; do
    local repo="${OMZ_CUSTOM_PLUGIN_REPOS_URLS[$i]}"
    local dest="${plugin_dir}/${plugin}"
    if [[ ! -d "$dest" ]]; then
      git clone "$repo" "$dest" 2>/dev/null
    fi
    i=$((i + 1))
  done
}
