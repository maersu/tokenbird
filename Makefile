.PHONY: run run-force clear-cache refresh restart-waybar config config-path log help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  make %-16s %s\n", $$1, $$2}'

run: ## Run tokenbird (uses cache)
	@tokenbird

run-force: ## Run tokenbird, bypass cache
	@tokenbird --force

clear-cache: ## Delete cached data
	@rm -f ~/.cache/tokenbird/data.json
	@echo "Cache cleared"

refresh: ## Clear cache + signal waybar to update
	@rm -f ~/.cache/tokenbird/data.json
	@pkill -SIGRTMIN+11 waybar 2>/dev/null || true
	@echo "Cache cleared, waybar signaled"

restart-waybar: ## Full waybar restart
	@omarchy-restart-waybar

config: ## Open config in editor
	@$${EDITOR:-cursor} ~/.config/tokenbird/config.json

config-path: ## Print config file path
	@echo ~/.config/tokenbird/config.json

log: ## Run with --force and pretty-print JSON
	@tokenbird --force | python3 -m json.tool
