# iTerm Notification Setup

This guide configures iTerm2 native notifications for your AI coding tool.
When a task finishes or the AI needs your attention, you'll see a notification with the iTerm icon.

**Requirements**: macOS, iTerm2, `jq` (`brew install jq` — Claude Code only)

---

## For Claude Code

### Step 1: Create hook scripts

Create `~/.claude/hooks/stop-notify.sh`:

```bash
#!/bin/bash

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
[ -n "$TTY" ] && printf '\e]9;%s\a' "Claude Code: Task completed" > "$TTY"
```

Create `~/.claude/hooks/notify.sh`:

```bash
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
```

### Step 2: Make executable

```bash
chmod +x ~/.claude/hooks/stop-notify.sh ~/.claude/hooks/notify.sh
```

### Step 3: Add hooks to settings

Add the following to `~/.claude/settings.json` (merge into existing `hooks` if present):

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/stop-notify.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/notify.sh"
          }
        ]
      }
    ]
  }
}
```

### Step 4: Verify

Run this in your terminal to test:

```bash
printf '\e]9;%s\a' "iTerm Notification: Setup complete!"
```

You should see a notification with the iTerm icon.

---

## For OpenCode

### Step 1: Create plugin

Create `~/.config/opencode/plugins/notification.js`:

```javascript
import { writeFileSync } from "node:fs"
import { execSync } from "node:child_process"

export const NotificationPlugin = async ({ $ }) => {
  const termProgram = process.env.TERM_PROGRAM || ""

  const findTty = () => {
    let pid = process.pid
    while (pid > 1) {
      try {
        const tty = execSync(`ps -o tty= -p ${pid}`, { encoding: "utf-8" }).trim()
        if (tty && tty !== "??") return `/dev/${tty}`
        pid = parseInt(execSync(`ps -o ppid= -p ${pid}`, { encoding: "utf-8" }).trim(), 10)
      } catch { break }
    }
    return "/dev/tty"
  }
  const ttyDevice = findTty()

  const sendOsc = async (seq) => {
    try {
      if (process.env.TMUX) {
        const tty = (await $`tmux display-message -p '#{pane_tty}'`.text()).trim()
        writeFileSync(tty, `\x1bPtmux;\x1b\x1b]${seq}\x1b\x1b\\\x1b\\`)
      } else {
        writeFileSync(ttyDevice, `\x1b]${seq}\x1b\\`)
      }
    } catch {}
  }

  const notify = async (title, message) => {
    if (termProgram.startsWith("iTerm")) {
      await sendOsc(`9;${title}: ${message}`)
    } else {
      await sendOsc(`777;notify;${title};${message}`)
    }
  }

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await notify("OpenCode", "Task completed")
      }
      if (
        event.type === "session.status" &&
        event.properties?.status?.type === "idle"
      ) {
        await notify("OpenCode", "Task completed")
      }

      if (event.type === "permission.updated" || event.type === "question.asked") {
        await notify("OpenCode", "Needs your attention")
      }
    },
  }
}
```

### Step 2: Register plugin

Add to your OpenCode config (if using [oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode), disable its built-in notification hook to avoid duplicates):

The plugin auto-registers via the `~/.config/opencode/plugins/` directory.

### Step 3: Restart OpenCode

Plugin changes take effect after restart.

### Step 4: Verify

Ask your AI a question — you should see an iTerm notification when it needs your input.
