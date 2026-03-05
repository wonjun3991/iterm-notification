OPENCODE_PLUGINS := $(HOME)/.config/opencode/plugins
CLAUDE_HOOKS     := $(HOME)/.claude/hooks

.PHONY: install install-opencode install-claude uninstall uninstall-opencode uninstall-claude test

install: install-opencode install-claude
	@echo "Installed for both OpenCode and Claude Code."

install-opencode:
	@mkdir -p $(OPENCODE_PLUGINS)
	cp plugin/notification.js $(OPENCODE_PLUGINS)/notification.js
	@echo "OpenCode: installed to $(OPENCODE_PLUGINS)/notification.js"

install-claude:
	@mkdir -p $(CLAUDE_HOOKS)
	cp hooks/claude-code/stop-notify.sh $(CLAUDE_HOOKS)/stop-notify.sh
	cp hooks/claude-code/notify.sh $(CLAUDE_HOOKS)/notify.sh
	chmod +x $(CLAUDE_HOOKS)/stop-notify.sh $(CLAUDE_HOOKS)/notify.sh
	@echo "Claude Code: installed hooks to $(CLAUDE_HOOKS)/"
	@echo ""
	@echo "Add to ~/.claude/settings.json (hooks section):"
	@echo '  "Stop": [{"hooks": [{"type": "command", "command": "~/.claude/hooks/stop-notify.sh"}]}],'
	@echo '  "Notification": [{"hooks": [{"type": "command", "command": "~/.claude/hooks/notify.sh"}]}]'

uninstall: uninstall-opencode uninstall-claude

uninstall-opencode:
	rm -f $(OPENCODE_PLUGINS)/notification.js
	@echo "OpenCode: uninstalled."

uninstall-claude:
	rm -f $(CLAUDE_HOOKS)/stop-notify.sh $(CLAUDE_HOOKS)/notify.sh
	@echo "Claude Code: uninstalled."

test:
	@printf '\e]9;%s\a' "iTerm Notification: Test - click to focus iTerm!"
