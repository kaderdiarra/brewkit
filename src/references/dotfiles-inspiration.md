# Dotfiles & Setup Inspiration

External repos worth referencing when building your own setup.

## ColeCaccamise/dotfiles

- **Repo**: https://github.com/ColeCaccamise/dotfiles

### Key takeaway

A Brewfile + dotfiles repo + a reload script = reproducible setup on any new Mac. Run `brew bundle` to install everything, clone your dotfiles, run the config script, done.

---

### .zshrc

```bash
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

autoload -U promptinit; promptinit
prompt pure

CASE_SENSITIVE="true"

plugins=(git docker)

source $ZSH/oh-my-zsh.sh

export EDITOR='code -w'
export TERM=xterm-256color

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# -------
# Aliases
# -------
alias o="open ."
alias ghost="gs"
alias lint="npx next lint"
alias ng="ngrok http --url=caccamedia.ngrok.dev"
alias c="clear"
alias lg="lazygit"
alias sz="source ~/.zshrc"
alias csh="~/dotfiles/config.sh"

# -------
# pnpm Aliases
# -------
alias p="pnpm"
alias pi="pnpm install"
alias pa="pnpm add"
alias pd="pnpm dev"
alias pb="pnpm build"
alias pr="pnpm run"
alias psd="pnpm start:dev"

# ----------------------
# bun Aliases
# ----------------------
alias b="bun"
alias bi="bun install"
alias ba="bun add"
alias bd="bun dev"
alias bm="bun run migrate"
alias bmm="bun run migrate:make"

# ----------------------
# Git Aliases
# ----------------------
alias gi='git init'
alias gro='git remote add origin'
alias ga='git add'
alias gaa='git add .'
alias gcm='git commit -m'
alias gpsh='git push'
alias gpsho='git push -u origin'
alias gss='git status -s'
alias gs='echo ""; echo "*********************************************"; echo -e "   DO NOT FORGET TO PULL BEFORE COMMITTING"; echo "*********************************************"; echo ""; git status'

# ----------------------
# Docker Aliases
# ----------------------
alias d='docker'
alias dps='docker ps'
alias dc='docker compose'
alias dcu='docker compose up'
alias dcd='docker compose down'
alias dcud='docker compose up -d'
alias ds='docker sandbox'
alias dsls='docker sandbox ls'
alias dcs='docker sandbox run --template ghcr.io/byga-net/custom-docker-sandbox:latest claude'

# ----------------------
# Rails Aliases
# ----------------------
alias rc='rails c'
alias rdm='rake db:migrate'
alias rdb='rake db:rollback'
alias bi='bundle install'
alias rrg='rake routes | grep'

# ----------------------
# Vercel Aliases
# ----------------------
alias v='vercel'
alias vb='vercel build'
alias vd='vercel deploy'
alias vls='vercel ls'
alias vpr='vercel pull --environment=production'
alias vps='vercel pull --environment=preview'
alias vpsh='vercel push --environment=preview'
alias vpsh='vercel push --environment=production'

# ----------------------
# Neovim Aliases
# ----------------------
alias vim='nvim'
alias nv='nvim'

# ----------------------
# Eza Aliases
# ----------------------
alias ls='eza --git --group-directories-first --icons'
alias l='eza --git --group-directories-first --icons'
alias ll='eza --git --group-directories-first --icons -alF'
alias la='eza --git --group-directories-first --icons -a'

# ----------------------
# Stripe Aliases
# ----------------------
alias sl='stripe login'
alias slf='stripe listen --forward-to'
```

---

### .gitconfig

```ini
[user]
	name = Cole Caccamise
	email = colecaccamise@gmail.com
[init]
  defaultBranch = main
[color]
  ui = auto
  diff = auto
  status = auto
  branch = auto
  interactive = auto
[alias]
    ls = !eza --git --group-directories-first --icons
    ll = !eza --git --group-directories-first --icons -l
    la = !eza --git --group-directories-first --icons -la
```

---

### Brewfile

```ruby
tap "homebrew/bundle"
tap "homebrew/services"
tap "rbenv/tap"
tap "stripe/stripe-cli"
brew "zstd"
brew "autoconf"
brew "automake"
brew "openssl@3"
brew "coreutils"
brew "emacs"
brew "gh"
brew "git"
brew "gnu-tar"
brew "node"
brew "heroku"
brew "imagemagick"
brew "k6"
brew "libksba"
brew "libyaml"
brew "mailhog", restart_service: :changed
brew "zlib"
brew "mysql", restart_service: :changed
brew "netcat"
brew "pkgconf"
brew "pure"
brew "rbenv"
brew "rbspy"
brew "telnet"
brew "tldr"
brew "vim"
brew "zsh"
brew "rbenv/tap/openssl@1.1"
brew "stripe/stripe-cli/stripe"
cask "ghostty"
cask "iterm2"
cask "itsycal"
cask "linearmouse"
cask "ngrok"
cask "utm"
vscode "aaron-bond.better-comments"
vscode "achaq.vercel-theme"
vscode "alefragnani.project-manager"
vscode "bradlc.vscode-tailwindcss"
vscode "bung87.vscode-gemfile"
vscode "chrmarti.regex"
vscode "dawranliou.minimal-theme-vscode"
vscode "donjayamanne.githistory"
vscode "dotenv.dotenv-vscode"
vscode "eamodio.gitlens"
vscode "enkia.tokyo-night"
vscode "esbenp.prettier-vscode"
vscode "figma.figma-vscode-extension"
vscode "firsttris.vscode-jest-runner"
vscode "formulahendry.auto-rename-tag"
vscode "github.remotehub"
vscode "github.vscode-github-actions"
vscode "github.vscode-pull-request-github"
vscode "golang.go"
vscode "icrawl.discord-vscode"
vscode "illixion.vscode-vibrancy-continued"
vscode "johnpapa.vscode-peacock"
vscode "k--kato.intellij-idea-keybindings"
vscode "kisstkondoros.vscode-gutter-preview"
vscode "lewxdev.vscode-glyph"
vscode "mintlify.document"
vscode "ms-azuretools.vscode-docker"
vscode "ms-python.debugpy"
vscode "ms-python.python"
vscode "ms-python.vscode-pylance"
vscode "ms-vscode-remote.remote-containers"
vscode "ms-vscode-remote.remote-ssh"
vscode "ms-vscode-remote.remote-ssh-edit"
vscode "ms-vscode.azure-repos"
vscode "ms-vscode.makefile-tools"
vscode "ms-vscode.remote-explorer"
vscode "ms-vscode.remote-repositories"
vscode "naumovs.color-highlight"
vscode "nichabosh.minimalist-dark"
vscode "oderwat.indent-rainbow"
vscode "optimizion.vscode-minimal-theme"
vscode "pmndrs.pmndrs"
vscode "postman.postman-for-vscode"
vscode "raunofreiberg.vesper"
vscode "rebornix.ruby"
vscode "s-nlf-fh.glassit"
vscode "shan.code-settings-sync"
vscode "shopify.ruby-extensions-pack"
vscode "shopify.ruby-lsp"
vscode "sianglim.slim"
vscode "sorbet.sorbet-vscode-extension"
vscode "streetsidesoftware.code-spell-checker"
vscode "tomoki1207.pdf"
vscode "wayou.vscode-todo-highlight"
vscode "wingrunr21.vscode-ruby"
vscode "wix.vscode-import-cost"
```

---

### config.sh

```bash
#! /bin/bash

DOTFILES=(.gitconfig .zshrc)

for dotfile in "${DOTFILES[@]}"; do
    ln -sf ~/dotfiles/"$dotfile" ~/"$dotfile"
done
```

---

### reload-dotfiles.sh

Raycast script to quickly reload dotfiles:

```bash
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Reload dotfiles
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

sh ~/dotfiles/config.sh
```

---
---

## w3cj/dotfiles (CodingGarden)

- **Repo**: https://github.com/w3cj/dotfiles
- **VS Code settings & extensions**: https://github.com/CodingGarden/vscode-settings

### Key takeaway

Minimal setup — robbyrussell theme, git plugin only, simple aliases, nano as editor. VS Code config is extensively documented with settings JSON and full extension list.

---

### .zshrc

```bash
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
CASE_SENSITIVE="true"
ENABLE_CORRECTION="true"

plugins=(git)

source $ZSH/oh-my-zsh.sh

export EDITOR='nano'

# -------
# Aliases
# -------
alias l="ls" # List files in current directory
alias ll="ls -al" # List all files in current directory in long list format
alias o="open ." # Open the current directory in Finder

# ----------------------
# Git Aliases
# ----------------------
alias gaa='git add .'
alias gcm='git commit -m'
alias gpsh='git push'
alias gss='git status -s'
alias gs='echo ""; echo "*********************************************"; echo -e "   DO NOT FORGET TO PULL BEFORE COMMITTING"; echo "*********************************************"; echo ""; git status'
```

---

### .gitconfig

```ini
[user]
	name = w3cj
	email = cj@null.computer
[core]
	editor = nano
[init]
	defaultBranch = main
```

---

### config.sh

```bash
#! /bin/bash

DOTFILES=(.bash_profile .gitconfig .gitignore .zshrc)

for dotfile in $(echo ${DOTFILES[*]});
do
    cp ~/dotfiles/$(echo $dotfile) ~/$(echo $dotfile)
done
```

---

### VS Code Settings (from CodingGarden/vscode-settings)

**Font**: Anonymous Pro
**Theme**: Just Black
**Icon Theme**: vscode-icons

**Key settings**:
```json
{
  "workbench.sideBar.location": "right",
  "workbench.statusBar.visible": false,
  "workbench.editor.showTabs": "none",
  "editor.fontFamily": "Anonymous Pro",
  "editor.fontSize": 13,
  "editor.linkedEditing": true,
  "editor.minimap.enabled": false,
  "editor.snippetSuggestions": "top",
  "editor.tabSize": 2,
  "files.autoSave": "onWindowChange"
}
```

**Extensions**:
```
nur.just-black
fosshaas.fontsize-shortcuts
vscode-icons-team.vscode-icons
dbaeumer.vscode-eslint
esbenp.prettier-vscode
quicktype.quicktype
vunguyentuan.vscode-postcss
streetsidesoftware.code-spell-checker
yoavbls.pretty-ts-errors
adpyke.codesnap
rangav.vscode-thunder-client
DotJoshJohnson.xml
bradlc.vscode-tailwindcss
dsznajder.es7-react-js-snippets
Vue.volar
svelte.svelte-vscode
Prisma.prisma
otovo-oss.htmx-tags
bierner.markdown-mermaid
```
