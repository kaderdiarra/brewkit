.PHONY: install install-dry install-verbose uninstall uninstall-dry verify update info browse logs help

install: ## Run the interactive installer
	@bash install.sh

install-dry: ## Preview what would be installed (no changes)
	@bash install.sh --dry-run

install-verbose: ## Run installer with full command output
	@bash install.sh --verbose

uninstall: ## Interactively remove installed tools and apps
	@bash installer/uninstall.sh

uninstall-dry: ## Preview what would be removed (no changes)
	@bash installer/uninstall.sh --dry-run

verify: ## Check current install status of all tools and apps
	@bash installer/verify.sh

update: ## Pull latest config and re-run installer
	@bash installer/update.sh

info: ## List all tools or get details (usage: make info raycast)
	@bash installer/info.sh $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

browse: ## Interactive fuzzy search across all tools (requires gum)
	@bash installer/info.sh browse

%:
	@:

logs: ## Show the most recent install log
	@ls -t logs/install-*.log 2>/dev/null | head -1 | xargs cat 2>/dev/null || echo "No install logs found. Run 'make install' first."

help: ## Show available commands
	@echo ""
	@echo "  Brewkit"
	@echo "  ──────────────────"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  Shell Commands (available after install)"
	@echo "  ──────────────────"
	@echo ""
	@printf "  \033[36m%-20s\033[0m %s\n" "keys" "Show keyboard shortcuts for installed tools"
	@printf "  \033[36m%-20s\033[0m %s\n" "keys <tool>" "Show shortcuts for a specific tool (e.g. keys vscode)"
	@printf "  \033[36m%-20s\033[0m %s\n" "keys help" "Show keys usage and available tools"
	@printf "  \033[36m%-20s\033[0m %s\n" "aliases" "Show all shell aliases"
	@printf "  \033[36m%-20s\033[0m %s\n" "aliases <group>" "Show aliases for a group (e.g. aliases git)"
	@printf "  \033[36m%-20s\033[0m %s\n" "aliases help" "Show aliases usage and available groups"
	@echo ""
