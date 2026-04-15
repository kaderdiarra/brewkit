# Homebrew

The missing package manager for macOS — install, update, and manage CLI tools and desktop apps from the terminal.

- **Website**: https://brew.sh

## Install

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Post-Install (Apple Silicon only)

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

This adds `/opt/homebrew/bin` to your PATH. Intel Macs don't need this step.
