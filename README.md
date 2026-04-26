# Brewkit

Opinionated macOS dev environment setup with an interactive CLI wizard. Pick a bundle or customize — apps, dev tools, editor extensions, shell config, and system preferences, all automated.

<!-- TODO: Add a GIF/screenshot of the installer in action -->
<!-- ![Installer demo](assets/demo.gif) -->

## Quick Start

```bash
git clone https://github.com/kaderdiarra/brewkit.git
cd brewkit
make install
```

> **Dry run first?** Run `make install-dry` to preview every command without making changes.

## Requirements

- macOS 12+ (Monterey or later)
- Admin access (for Homebrew and system preferences)
- That's it — the installer handles Xcode CLI tools, Homebrew, and all dependencies

## How It Works

The installer is a 6-phase wizard that guides you through everything:

1. **Prerequisites** — installs Xcode CLI tools, Homebrew, and gum (interactive UI)
2. **Selection** — pick a bundle or custom-select individual items
3. **Resolution** — detects what's already installed, builds an install plan
4. **Confirmation** — shows a summary and asks before touching anything
5. **Installation** — installs everything with progress tracking
6. **Configuration** — sets up Git, SSH keys, shell aliases, system preferences

### Bundles

| Bundle | What's included |
|--------|----------------|
| **Minimal** | Core tools — terminal, launcher, git, font |
| **Web Dev** | Full-stack web dev essentials — Node.js, extensions, linting |
| **Full** | Everything in the config |
| **Custom** | Pick and choose what you want |

### Features

- **Idempotent** — safe to re-run, skips what's already installed
- **Graceful fallback** — works without gum (basic terminal prompts)
- **Dry run** — preview all commands before executing
- **Verbose mode** — see full brew output with `--verbose`
- **Signal handling** — clean interruption with Ctrl+C
- **Logging** — all output saved to `logs/`
- **Exportable** — save your selections to replay later

## Commands

```bash
make install           # Run the interactive installer
make install-dry       # Preview what would be installed (no changes)
make install-verbose   # Run installer with full command output
make verify            # Check current install status of all tools and apps
make info              # Browse all available tools with install status
make info raycast    # Get details on a specific tool (name, URL, status)
make update            # Pull latest config and re-run installer
make logs              # Show the most recent install log
make help              # Show all available commands
```

## What's Included

### Apps

| App | Description |
|-----|-------------|
| [AltTab](src/apps/alttab.md) | Windows-style alt-tab with window previews |
| [Arc](src/apps/arc.md) | Chromium browser with sidebar tabs & workspaces |
| [DBeaver](src/apps/dbeaver.md) | Universal database management tool |
| [Hidden Bar](src/apps/hidden-bar.md) | Menu bar icon manager |
| [iTerm2](src/apps/iterm2.md) | Terminal emulator — split panes, search, profiles |
| [itsycal](src/apps/itsycal.md) | Menu bar calendar with events |
| [Kap](src/apps/kap.md) | Screen recorder — GIF, MP4, WebM |
| [Keka](src/apps/keka.md) | File archiver — 7z, ZIP, RAR |
| [NotchNook](src/apps/notchnook.md) | MacBook notch utility area |
| [Raycast](src/apps/raycast.md) | Spotlight replacement with extensions |
| [Rectangle](src/apps/rectangle.md) | Window management with keyboard shortcuts |
| [Stats](src/apps/stats.md) | Menu bar system monitor |
| [Sublime Text](src/apps/sublime-text.md) | Lightweight text editor for quick edits |
| [Time Out](src/apps/time-out.md) | Break timer to prevent strain |

### Dev Tools

| Tool | Description |
|------|-------------|
| [CLI Tools](src/dev-tools/cli-tools.md) | wget, telnet, tldr |
| [Fira Code](src/dev-tools/fira-code.md) | Developer font with programming ligatures |
| [Git](src/dev-tools/git.md) | Version control + SSH key setup for GitHub |
| [Homebrew](src/dev-tools/homebrew.md) | macOS package manager |
| [NVM](src/dev-tools/nvm.md) | Node.js version manager + global npm packages |
| [Oh My Zsh](src/dev-tools/oh-my-zsh.md) | Zsh framework — themes, plugins, aliases |

### System

| Config | Description |
|--------|-------------|
| [macOS Settings](src/system/macos-settings.md) | Dock, Finder, hot corners, login items, display |

### Editor — VS Code

[Setup & settings](src/editor/vscode.md) | [46 curated extensions](src/editor/extensions/)

<details>
<summary><strong>Extensions by category</strong> (click to expand)</summary>

#### Essentials

| Extension | Description |
|-----------|-------------|
| [Auto Close Tag](src/editor/extensions/auto-close-tag.md) | Auto-insert closing HTML/XML tags |
| [Auto Rename Tag](src/editor/extensions/auto-rename-tag.md) | Auto-rename paired HTML/XML tags |
| [Code Spell Checker](src/editor/extensions/code-spell-checker.md) | Catch spelling mistakes in code |
| [DotENV](src/editor/extensions/dotenv.md) | Syntax highlighting for .env files |
| [Error Lens](src/editor/extensions/error-lens.md) | Show errors/warnings inline |
| [ESLint](src/editor/extensions/eslint.md) | JS/TS linting with inline errors and auto-fix |
| [Prettier](src/editor/extensions/prettier.md) | Opinionated code formatter |
| [Pretty TypeScript Errors](src/editor/extensions/pretty-typescript-errors.md) | Human-readable TypeScript errors |

#### Productivity

| Extension | Description |
|-----------|-------------|
| [Auto Barrel](src/editor/extensions/auto-barrel.md) | Auto-generate barrel (index.ts) export files |
| [Better Comments](src/editor/extensions/better-comments.md) | Color-coded comments by type |
| [Bookmarks](src/editor/extensions/bookmarks.md) | Mark and jump between bookmarked lines |
| [Code Runner](src/editor/extensions/code-runner.md) | Run code snippets in 40+ languages |
| [CodeSnap](src/editor/extensions/codesnap.md) | Take beautiful code screenshots |
| [Font Size Shortcuts](src/editor/extensions/font-size-shortcuts.md) | Change font size without zooming UI |
| [Import Cost](src/editor/extensions/import-cost.md) | Show imported package bundle size inline |
| [Paste JSON as Code](src/editor/extensions/paste-json-as-code.md) | Convert JSON to TypeScript types and more |
| [Peacock](src/editor/extensions/peacock.md) | Color-code your workspaces |
| [Project Manager](src/editor/extensions/project-manager.md) | Switch between projects quickly |
| [Todo Tree](src/editor/extensions/todo-tree.md) | Tree view of TODO/FIXME across project |
| [Turbo Console Log](src/editor/extensions/turbo-console-log.md) | Insert console.log with shortcuts |

#### IntelliSense

| Extension | Description |
|-----------|-------------|
| [IntelliSense (Path + npm)](src/editor/extensions/intellisense.md) | Autocomplete file paths and npm modules |
| [PostCSS IntelliSense](src/editor/extensions/postcss-intellisense.md) | Syntax highlighting & intellisense for PostCSS |
| [Tailwind CSS IntelliSense](src/editor/extensions/tailwind-css-intellisense.md) | Autocomplete & preview for Tailwind classes |

#### Snippets

| Extension | Description |
|-----------|-------------|
| [ES7+ React Snippets](src/editor/extensions/react-snippets.md) | React, Redux, and JavaScript snippets |

#### Git

| Extension | Description |
|-----------|-------------|
| [GitHub Copilot](src/editor/extensions/github-copilot.md) | AI-powered code completion |
| [GitHub Pull Requests](src/editor/extensions/github-pr.md) | Review and manage PRs from VS Code |
| [GitLens](src/editor/extensions/gitlens.md) | Git blame, history, and code authorship |

#### Testing

| Extension | Description |
|-----------|-------------|
| [Testing (Jest + Playwright)](src/editor/extensions/testing.md) | Jest Runner, Jest, Playwright integration |

#### Tools

| Extension | Description |
|-----------|-------------|
| [Docker](src/editor/extensions/docker.md) | Manage containers and images from VS Code |
| [Thunder Client](src/editor/extensions/thunder-client.md) | Lightweight REST API client |
| [Excalidraw](src/editor/extensions/excalidraw.md) | Whiteboard and diagramming tool |

#### Media

| Extension | Description |
|-----------|-------------|
| [Paste Image & Image Preview](src/editor/extensions/paste-image-preview.md) | Paste & preview images in code comments |

#### Remote Development

| Extension | Description |
|-----------|-------------|
| [Remote Development](src/editor/extensions/remote-development.md) | SSH, Containers, Remote Explorer |

#### Languages

| Extension | Description |
|-----------|-------------|
| [Language Support (YAML, MDX)](src/editor/extensions/language-support.md) | YAML and MDX language support |

#### Vim

| Extension | Description |
|-----------|-------------|
| [Vim Extension](src/editor/extensions/vim.md) | Vim keybindings + cheatsheet + learn-vim tutorial |

#### Themes & Icons

| Extension | Description |
|-----------|-------------|
| [Themes & Icons](src/editor/extensions/theme-and-icons.md) | GitHub Theme, One Dark Pro, Material icons |

</details>

## Project Structure

```
.
├── src/                # Configuration reference docs
│   ├── apps/           # macOS applications (one doc per app)
│   ├── dev-tools/      # CLI tools, runtimes, fonts
│   ├── editor/         # VS Code setup & extensions
│   │   └── extensions/ # One doc per extension (or grouped)
│   ├── system/         # macOS system preferences
│   └── references/     # External dotfiles & inspiration
├── installer/          # Interactive CLI installer
│   ├── lib/            # Shared utilities (colors, checks, UI, logging)
│   ├── registry/       # Data-driven tool/app definitions
│   ├── phases/         # Installation phases
│   └── bundles.sh      # Predefined setup bundles
└── install.sh          # Entry point
```

## Adding New Tools

Add one entry to the appropriate registry file:

```bash
# installer/registry/apps.sh
"myapp|My App|--cask myapp|app|/Applications/My App.app|Description here"

# installer/registry/dev-tools.sh
"mytool|My Tool|brew:mytool|command|mytool|Description here"

# installer/registry/editor.sh
"myext|My Extension|publisher.extension-id|Description|category"
```

Then add the key to any bundles in `installer/bundles.sh` where it should be included.

## Contributing

Found a tool worth adding? Have a better config? Contributions are welcome.

- **Add a tool/app/extension** — follow the [Adding New Tools](#adding-new-tools) guide above and open a PR
- **Suggest improvements** — open an [issue](https://github.com/kaderdiarra/brewkit/issues) with your idea
- **Fix a bug** — fork, fix, PR

Keep it simple: one tool per registry entry, one doc per tool, test with `make install-dry` before submitting.

## References

| Resource | Description |
|----------|-------------|
| [Dotfiles & Setup Inspiration](src/references/dotfiles-inspiration.md) | External dotfiles repos, Brewfiles, VS Code configs |
