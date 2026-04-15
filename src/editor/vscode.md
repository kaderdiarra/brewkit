# VS Code

Free, open-source code editor by Microsoft — debugging, Git integration, IntelliSense, and a massive extension ecosystem.

- **Website**: https://code.visualstudio.com

## Install

```bash
brew install --cask visual-studio-code
```

## Setup

1. Add `code` to PATH: `Cmd+Shift+P` → "Shell Command: Install 'code' command in PATH"
2. Enable **Settings Sync**: `Cmd+Shift+P` → "Settings Sync: Turn On" (backs up to GitHub/Microsoft account)
3. Set default formatter & enable **Format On Save** in `Settings (Cmd+,)`

## Recommended Settings

Open user settings JSON: `Cmd+Shift+P` → "Open User Settings (JSON)"

```json
{
  "workbench.sideBar.location": "right",
  "workbench.statusBar.visible": false,
  "workbench.editor.showTabs": "none",
  "editor.snippetSuggestions": "top",
  "editor.minimap.enabled": false,
  "editor.linkedEditing": true
}
```

| Setting | Why |
|---------|-----|
| Sidebar on right | Opening/closing sidebar doesn't shift your code |
| Hide status bar | Cleaner layout, toggle with `Cmd+Shift+P` when needed |
| Hide tabs | Use `Ctrl+Tab` to switch files instead |
| Snippets on top | No need to arrow down to reach snippet completions |
| Disable minimap | More horizontal space for code |
| Linked editing | Auto-rename closing HTML tag when editing the opening tag |
