.PHONY: install uninstall waybar-add waybar-remove run run-force clear-cache refresh restart-waybar config config-path log help

BIN_DIR     := $(HOME)/.local/bin
CFG_DIR     := $(HOME)/.config/tokenbird
WAYBAR_CFG  := $(HOME)/.config/waybar/config-custom.jsonc
WAYBAR_MAIN := $(HOME)/.config/waybar/config.jsonc

install: ## Symlink tokenbird into PATH and create config
	@mkdir -p $(BIN_DIR)
	@ln -sf "$(CURDIR)/tokenbird" $(BIN_DIR)/tokenbird
	@echo "Linked $(BIN_DIR)/tokenbird → $(CURDIR)/tokenbird"
	@if [ ! -f $(CFG_DIR)/config.json ]; then \
		mkdir -p $(CFG_DIR); \
		cp config.example.json $(CFG_DIR)/config.json; \
		echo "Created $(CFG_DIR)/config.json — edit it with your API keys"; \
	else \
		echo "Config already exists at $(CFG_DIR)/config.json (kept)"; \
	fi

uninstall: ## Remove symlink and cache (keeps config)
	@rm -f $(BIN_DIR)/tokenbird
	@rm -rf $(HOME)/.cache/tokenbird
	@echo "Removed tokenbird binary and cache (config kept at $(CFG_DIR)/)"

waybar-add: ## Add tokenbird module to Waybar and restart
	@python3 -c "\
import json;\
p='$(WAYBAR_CFG)'; c=json.load(open(p));\
new='custom/tokenbird' not in c;\
c.setdefault('custom/tokenbird',{'exec':'tokenbird','return-type':'json','format':'{}','interval':600,'signal':11,'on-click':'pkill -SIGRTMIN+11 waybar','tooltip':True});\
f=open(p,'w'); json.dump(c,f,indent=2); f.write('\n'); f.close();\
print(('Added module to' if new else 'Module already in'),p)"
	@python3 -c "\
import json;\
p='$(WAYBAR_MAIN)'; c=json.load(open(p)); m=c.get('modules-right',[]);\
new='custom/tokenbird' not in m;\
(m.insert(next((i for i,x in enumerate(m) if x=='group/tray-expander'),0),'custom/tokenbird') if new else None);\
c['modules-right']=m; f=open(p,'w'); json.dump(c,f,indent=2); f.write('\n'); f.close();\
print(('Added to modules-right in' if new else 'Already in modules-right in'),p)"
	@omarchy-restart-waybar 2>/dev/null && echo "Waybar restarted" || echo "Restart waybar manually: omarchy-restart-waybar"

waybar-remove: ## Remove tokenbird module from Waybar and restart
	@python3 -c "\
import json;\
p='$(WAYBAR_CFG)'; c=json.load(open(p));\
removed=c.pop('custom/tokenbird',None) is not None;\
f=open(p,'w'); json.dump(c,f,indent=2); f.write('\n'); f.close();\
print(('Removed module from' if removed else 'Module not in'),p)"
	@python3 -c "\
import json;\
p='$(WAYBAR_MAIN)'; c=json.load(open(p)); m=c.get('modules-right',[]);\
removed='custom/tokenbird' in m;\
(m.remove('custom/tokenbird') if removed else None);\
c['modules-right']=m; f=open(p,'w'); json.dump(c,f,indent=2); f.write('\n'); f.close();\
print(('Removed from modules-right in' if removed else 'Not in modules-right in'),p)"
	@omarchy-restart-waybar 2>/dev/null && echo "Waybar restarted" || echo "Restart waybar manually: omarchy-restart-waybar"

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
