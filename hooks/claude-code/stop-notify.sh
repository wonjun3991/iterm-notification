#!/bin/bash
APP_PATH="${ITERM_NOTIFIER_APP:-$(dirname "$0")/OpenCodeNotifier.app}"

if [ -d "$APP_PATH" ]; then
  open "$APP_PATH" --args "Claude Code" "Task completed"
else
  osascript -e 'display notification "Task completed" with title "Claude Code"'
fi
