APP_NAME := OpenCodeNotifier
APP_BUNDLE := app/$(APP_NAME).app
BINARY := $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)
SRC := src/$(APP_NAME).swift

OPENCODE_DIR := $(HOME)/.config/opencode/plugins
CLAUDE_DIR := $(HOME)/.claude
CLAUDE_HOOKS_DIR := $(CLAUDE_DIR)/hooks

.PHONY: build install install-opencode install-claude uninstall uninstall-opencode uninstall-claude clean test

build: $(BINARY)

$(BINARY): $(SRC) app/Contents/Info.plist
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	@cp app/Contents/Info.plist $(APP_BUNDLE)/Contents/Info.plist
	swiftc -o $@ $< -framework Cocoa -framework UserNotifications
	@echo "Built $(APP_BUNDLE)"

install: build install-opencode install-claude
	@echo "Installed for both OpenCode and Claude Code."

install-opencode: build
	@mkdir -p $(OPENCODE_DIR)
	@rm -rf $(OPENCODE_DIR)/$(APP_NAME).app
	cp -R $(APP_BUNDLE) $(OPENCODE_DIR)/$(APP_NAME).app
	cp plugin/notification.js $(OPENCODE_DIR)/notification.js
	@echo "OpenCode: installed to $(OPENCODE_DIR)"

install-claude: build
	@mkdir -p $(CLAUDE_HOOKS_DIR)
	@rm -rf $(CLAUDE_HOOKS_DIR)/$(APP_NAME).app
	cp -R $(APP_BUNDLE) $(CLAUDE_HOOKS_DIR)/$(APP_NAME).app
	cp hooks/claude-code/stop-notify.sh $(CLAUDE_HOOKS_DIR)/stop-notify.sh
	cp hooks/claude-code/notify.sh $(CLAUDE_HOOKS_DIR)/notify.sh
	chmod +x $(CLAUDE_HOOKS_DIR)/stop-notify.sh $(CLAUDE_HOOKS_DIR)/notify.sh
	@echo "Claude Code: installed to $(CLAUDE_HOOKS_DIR)"
	@echo ""
	@echo "Add to ~/.claude/settings.json:"
	@echo '  "hooks": {'
	@echo '    "Stop": [{"hooks": [{"type": "command", "command": "~/.claude/hooks/stop-notify.sh"}]}],'
	@echo '    "Notification": [{"hooks": [{"type": "command", "command": "~/.claude/hooks/notify.sh"}]}]'
	@echo '  }'

uninstall: uninstall-opencode uninstall-claude

uninstall-opencode:
	rm -rf $(OPENCODE_DIR)/$(APP_NAME).app
	rm -f $(OPENCODE_DIR)/notification.js
	@echo "OpenCode: uninstalled."

uninstall-claude:
	rm -rf $(CLAUDE_HOOKS_DIR)/$(APP_NAME).app
	rm -f $(CLAUDE_HOOKS_DIR)/stop-notify.sh
	rm -f $(CLAUDE_HOOKS_DIR)/notify.sh
	@echo "Claude Code: uninstalled."

clean:
	rm -rf $(APP_BUNDLE)

test: build
	open $(APP_BUNDLE) --args "iTerm Notification" "Test - click to focus iTerm!"
