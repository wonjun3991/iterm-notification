APP_NAME := OpenCodeNotifier
APP_BUNDLE := app/$(APP_NAME).app
BINARY := $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)
SRC := src/$(APP_NAME).swift
INSTALL_DIR := $(HOME)/.config/opencode/plugins

.PHONY: build install uninstall clean test

build: $(BINARY)

$(BINARY): $(SRC) app/Contents/Info.plist
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	@cp app/Contents/Info.plist $(APP_BUNDLE)/Contents/Info.plist
	swiftc -o $@ $< -framework Cocoa -framework UserNotifications
	@echo "Built $(APP_BUNDLE)"

install: build
	@mkdir -p $(INSTALL_DIR)
	@rm -rf $(INSTALL_DIR)/$(APP_NAME).app
	cp -R $(APP_BUNDLE) $(INSTALL_DIR)/$(APP_NAME).app
	cp plugin/notification.js $(INSTALL_DIR)/notification.js
	@echo "Installed to $(INSTALL_DIR)"
	@echo "Restart OpenCode to apply."

uninstall:
	rm -rf $(INSTALL_DIR)/$(APP_NAME).app
	rm -f $(INSTALL_DIR)/notification.js
	@echo "Uninstalled."

clean:
	rm -rf $(APP_BUNDLE)

test: build
	open $(APP_BUNDLE) --args "OpenCode" "Test notification - click to focus iTerm!"
