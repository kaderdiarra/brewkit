# Git

Distributed version control system for tracking source code changes.

- **Website**: https://git-scm.com

## Install

```bash
brew install git
```

## First-Time Config

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global init.defaultBranch main
```

## SSH Key Setup (for GitHub)

### Generate key

```bash
ssh-keygen -t ed25519 -C "your@email.com"
```

### Start SSH agent and add key

```bash
eval "$(ssh-agent -s)"
```

### Create/update SSH config

Add to `~/.ssh/config`:

```
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

### Add key to keychain and copy public key

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub
```

### Add to GitHub

Go to `GitHub > Settings > SSH and GPG Keys > New SSH Key` → paste the copied public key.
