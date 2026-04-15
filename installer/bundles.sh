#!/usr/bin/env bash
# Predefined installation bundles

BUNDLE_NAMES=("Minimal" "Web Dev" "Full" "Custom")
BUNDLE_KEYS=("minimal" "web-dev" "full" "custom")
BUNDLE_DESCS=(
  "Core tools only (terminal, launcher, git)"
  "Full-stack web development essentials"
  "Everything in the config project"
  "Pick and choose what you want"
)

# App keys per bundle (space-separated)
BUNDLE_APPS_minimal="raycast rectangle iterm2 hidden-bar"
BUNDLE_APPS_web_dev="raycast rectangle iterm2 hidden-bar alttab arc stats"
BUNDLE_APPS_full="ALL"

# Dev tool keys per bundle
BUNDLE_DEVTOOLS_minimal="git"
BUNDLE_DEVTOOLS_web_dev="git nvm oh-my-zsh wget tldr fira-code"
BUNDLE_DEVTOOLS_full="ALL"

# Extension keys per bundle
BUNDLE_EXTS_minimal="eslint prettier auto-rename-tag code-spell-checker error-lens"
BUNDLE_EXTS_web_dev="eslint prettier auto-rename-tag auto-close-tag code-spell-checker error-lens gitlens github-copilot github-pr tailwind-css npm-intellisense path-intellisense es7-react-snippets thunder-client todo-tree pretty-ts-errors dotenv turbo-console-log peacock project-manager vim"
BUNDLE_EXTS_full="ALL"

get_bundle_apps() {
  local bundle="$1"
  case "$bundle" in
    minimal) echo "$BUNDLE_APPS_minimal" ;;
    web-dev) echo "$BUNDLE_APPS_web_dev" ;;
    full)    echo "ALL" ;;
  esac
}

get_bundle_devtools() {
  local bundle="$1"
  case "$bundle" in
    minimal) echo "$BUNDLE_DEVTOOLS_minimal" ;;
    web-dev) echo "$BUNDLE_DEVTOOLS_web_dev" ;;
    full)    echo "ALL" ;;
  esac
}

get_bundle_exts() {
  local bundle="$1"
  case "$bundle" in
    minimal) echo "$BUNDLE_EXTS_minimal" ;;
    web-dev) echo "$BUNDLE_EXTS_web_dev" ;;
    full)    echo "ALL" ;;
  esac
}
