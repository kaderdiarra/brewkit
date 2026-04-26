#!/usr/bin/env bash
# Dev tools registry — pipe-delimited: "key|Display Name|install_method|check_type|check_value|description|url"

DEVTOOL_ENTRIES=(
  "git|Git|brew:git|command|git|Distributed version control|https://git-scm.com"
  "wget|wget|brew:wget|command|wget|Download files from the web|https://www.gnu.org/software/wget"
  "telnet|telnet|brew:telnet|command|telnet|Network debugging tool|"
  "tldr|tldr|brew:tldr|command|tldr|Simplified man pages|https://tldr.sh"
  "fira-code|Fira Code|cask:font-fira-code|cask|font-fira-code|Developer font with ligatures|https://github.com/tonsky/FiraCode"
  "nvm|NVM|custom:install_nvm|directory|$HOME/.nvm|Node.js version manager|https://github.com/nvm-sh/nvm"
  "oh-my-zsh|Oh My Zsh|custom:install_oh_my_zsh|directory|$HOME/.oh-my-zsh|Zsh framework with themes and plugins|https://ohmyz.sh"
  "claude-code|Claude Code|custom:install_claude_code|command|claude|AI coding agent for the terminal|https://claude.com/product/claude-code"
)

# NVM version — override with NVM_INSTALL_VERSION env var
NVM_DEFAULT_VERSION="v0.40.3"

install_nvm() {
  local nvm_version="${NVM_INSTALL_VERSION:-$NVM_DEFAULT_VERSION}"

  # Try to fetch latest version from GitHub
  local latest
  latest=$(curl -fsSL --connect-timeout 5 "https://api.github.com/repos/nvm-sh/nvm/releases/latest" 2>/dev/null | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"//;s/".*//')

  if [[ -n "$latest" && "$latest" =~ ^v[0-9] ]]; then
    nvm_version="$latest"
    log "NVM: using latest version $nvm_version"
  else
    log "NVM: couldn't fetch latest, using default $nvm_version"
  fi

  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh" | bash
}

install_oh_my_zsh() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
}

install_claude_code() {
  curl -fsSL https://claude.ai/install.sh | bash
}

install_node_lts() {
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm alias default node
}

install_npm_globals() {
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
  npm install -g lite-server http-server license gitignore
}
