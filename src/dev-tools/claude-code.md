# Claude Code

AI coding agent that lives in your terminal. Understands your codebase, edits files, runs commands, and works with git — all through natural language.

- **Website**: https://claude.com/product/claude-code
- **Docs**: https://docs.anthropic.com/en/docs/claude-code

## Install

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

## Usage

```bash
claude                    # Start interactive session in current directory
claude "fix the tests"    # One-shot command
claude --resume           # Resume last conversation
```

## Key Features

- Full codebase awareness — reads, edits, and creates files
- Runs shell commands, tests, and linters
- Git integration — commits, PRs, branch management
- MCP server support for external tools
- Hooks for custom automation on tool calls
- Project-level instructions via `CLAUDE.md`
