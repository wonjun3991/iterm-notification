#!/bin/bash
APP_PATH="${ITERM_NOTIFIER_APP:-$(dirname "$0")/OpenCodeNotifier.app}"

INPUT=$(cat)
MSG=$(echo "$INPUT" | jq -r '.message // "Needs your attention"')

if [ -d "$APP_PATH" ]; then
  open "$APP_PATH" --args "Claude Code" "$MSG"
else
  osascript -e "display notification \"$MSG\" with title \"Claude Code\""
fi
