#!/bin/bash

INPUT=$(cat)
MSG=$(echo "$INPUT" | jq -r '.message // "Needs your attention"')

# Walk up the process tree to find the TTY
find_tty() {
  local pid=$$
  while [ "$pid" -gt 1 ]; do
    local t
    t=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
    if [ -n "$t" ] && [ "$t" != "??" ]; then
      echo "/dev/$t"
      return
    fi
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
  done
}

TTY=$(find_tty)
[ -n "$TTY" ] && printf '\e]9;%s\a' "Claude Code: $MSG" > "$TTY"
