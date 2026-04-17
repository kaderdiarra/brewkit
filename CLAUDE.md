# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal MacBook setup reference + interactive installer. Two main parts:
1. **Documentation** — structured markdown docs covering tools, apps, editor config, and dev environment
2. **Installer** — interactive CLI (`make install`) that automates the setup using Bash + gum

## Architecture

```
src/               → Configuration reference docs
  apps/            → macOS applications (one .md per app)
  dev-tools/       → CLI tools and runtimes
  editor/          → Code editor setup
    extensions/    → Editor extensions (one .md per extension or group)
  system/          → macOS system preferences
  references/      → External dotfiles and setup repos
installer/         → Interactive CLI installer
  lib/             → Shared utilities (colors, checks, UI wrappers, logging)
  registry/        → Data-driven tool/app definitions (the source of truth)
  phases/          → Installation phases (prerequisites → select → resolve → install → configure)
  config/          → Default configuration files (VS Code settings)
  bundles.sh       → Predefined setup bundles (minimal, web-dev, full)
  verify.sh        → Standalone status checker for all registered tools
  info.sh          → Tool info browser (make info / make info t=<tool>)
```

## Commands

```bash
make install           # Run interactive installer
make install-dry       # Preview mode (no changes, shows exact commands)
make install-verbose   # Run with full command output visible
make verify            # Check install status of all tools and apps
make info              # Browse all tools with status
make info raycast    # Get details on a specific tool
make logs              # Show most recent install log
make help              # Show available commands
```

## Conventions

### Documentation
- One markdown file per tool/app (or grouped when tightly related)
- Each file follows: short description → links → install command → setup steps
- Keep docs concise — no fluff, just actionable info
- Prefer `brew install` / `brew install --cask` for installation commands
- README.md must stay updated as the table of contents (extensions grouped by category)

### Installer
- **Bash 3.2 compatible** — no `declare -A`, no associative arrays (macOS ships Bash 3.2)
- Registry pattern: adding a new tool = adding one entry to the appropriate registry file in `installer/registry/`
- Registry entries use pipe-delimited strings in indexed arrays with `get_field()` accessor — apps/devtools have 7 fields (last is URL), extensions have 6 fields (last is URL)
- Uses `gum` for interactive UI with automatic fallback to basic terminal prompts
- Phase-based execution: prerequisites → selection → dependency resolution → install → configure
- Idempotent: checks current state before acting, safe to re-run
- Shell modifications use marker comments (`# >>> brewkit >>>`) to avoid duplication
- System settings use structured fields (domain, key, type, value) — no `eval`
- Signal handling (Ctrl+C) with clean shutdown and partial progress report
- NVM version fetched dynamically from GitHub API with fallback default
- Logs written to `logs/` (gitignored)
- Selections can be exported to `my-selections.sh` for replay (gitignored)
