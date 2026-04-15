# Oh My Zsh

Open-source framework for managing Zsh configuration — themes, plugins, and helpers that enhance the terminal experience.

- **Website**: https://ohmyz.sh

## Install

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Setup

All configuration lives in `~/.zshrc`.

### Change Theme

```bash
ZSH_THEME="robbyrussell"  # default
```

Popular options: `robbyrussell`, `agnoster`, `powerlevel10k` (requires separate install)

### Enable Plugins

```bash
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker node npm)
```

Built-in plugins are in `~/.oh-my-zsh/plugins/`. Third-party plugins (like `zsh-autosuggestions`) must be cloned into `~/.oh-my-zsh/custom/plugins/` first.

### Reload After Changes

```bash
source ~/.zshrc
```
