# AeroSpace

i3-like tiling window manager for macOS. Automatic window tiling with workspaces, keyboard-driven. Power-user alternative to Rectangle — no SIP changes needed.

- **Website**: https://github.com/nikitabobko/AeroSpace
- **Docs**: https://nikitabobko.github.io/AeroSpace/guide

## Install

```bash
brew install --cask nikitabobko/tap/aerospace
```

## Setup

1. Launch AeroSpace and grant **Accessibility** permissions in `System Settings > Privacy & Security`
2. Config file at `~/.aerospace.toml` — see [default config](https://nikitabobko.github.io/AeroSpace/guide#default-config)

## Key Concepts

- **Tree-based tiling** — windows auto-arrange into splits (like i3)
- **Custom workspaces** — independent of macOS Spaces, switch with `Alt+1-9`
- **Keyboard-first** — all operations via keybindings, no mouse needed
- **Config-driven** — plain TOML file, version-controllable

## Default Shortcuts

| Action | Shortcut |
|--------|----------|
| Focus left/right/up/down | `Alt+H/L/K/J` |
| Move window | `Alt+Shift+H/L/K/J` |
| Switch workspace | `Alt+1-9` |
| Move to workspace | `Alt+Shift+1-9` |
| Toggle float | `Alt+Shift+F` |
| Resize | `Alt+Shift+-/=` |

## Rectangle vs AeroSpace

| | Rectangle | AeroSpace |
|---|---|---|
| Type | Window snapping | Tiling window manager |
| Workflow | Manual snap to positions | Automatic tiling + workspaces |
| Learning curve | Minimal | Moderate (i3 concepts) |
| Best for | Anyone | Keyboard-first power users |
