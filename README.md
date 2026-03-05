# iterm-notification

macOS notification helper that focuses iTerm2 when you click a notification.

## The Problem

On macOS, system notifications sent via `osascript` or basic shell commands open **Script Editor** when clicked, not your terminal. There's no built-in way to make a notification click bring iTerm2 to the front.

This project solves that by shipping a native macOS app bundle (`OpenCodeNotifier.app`) that uses `UNUserNotificationCenter`. Because the app owns the notification, macOS relaunches it when the user clicks. The app detects it was relaunched without arguments and activates iTerm2 instead.

## How It Works

```
Tool (OpenCode / Claude Code)
        |
        | open OpenCodeNotifier.app --args "Title" "Body"
        v
OpenCodeNotifier.app  (args present)
        |
        | UNUserNotificationCenter.add(request)
        v
macOS Notification Center  -->  [banner shown to user]
        |
        | user clicks banner
        v
macOS relaunches OpenCodeNotifier.app  (no args)
        |
        | NSWorkspace.activate(iTerm2)
        v
iTerm2 comes to the front
```

The dual-mode trick: the same binary does two things depending on whether arguments are present.

- **Args present** (`--args "Title" "Body"`): send a notification, then quit.
- **No args** (relaunched by macOS on click): activate iTerm2, then quit.

The app runs as a background-only process (`LSUIElement = true`) so it never appears in the Dock or App Switcher.

## Supported Platforms

| Tool | Integration |
|------|-------------|
| [OpenCode](https://opencode.ai) | `plugin/notification.js` (OpenCode plugin API) |
| [Claude Code](https://claude.ai/code) | Shell hooks in `hooks/claude-code/` |

Both require **iTerm2** on **macOS**.

## Prerequisites

- macOS
- Xcode Command Line Tools (`xcode-select --install`)
- `jq` (for Claude Code hooks only: `brew install jq`)

## Installation

### Build

```bash
make build
```

This compiles `src/OpenCodeNotifier.swift` and assembles the `.app` bundle under `app/`.

### Install for both tools

```bash
make install
```

### Install for OpenCode only

```bash
make install-opencode
```

Copies `OpenCodeNotifier.app` and `notification.js` to `~/.config/opencode/plugins/`.

Then register the plugin in your OpenCode config. If you use [oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode), disable its built-in notification hooks in `oh-my-opencode.json` to avoid conflicts.

### Install for Claude Code only

```bash
make install-claude
```

Copies `OpenCodeNotifier.app`, `stop-notify.sh`, and `notify.sh` to `~/.claude/hooks/`.

Then add the hooks to `~/.claude/settings.json`:

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

The `Stop` hook fires when a task finishes. The `Notification` hook fires when Claude Code needs your attention and reads a JSON payload from stdin (the `message` field is extracted with `jq`).

You can override the app path with the `ITERM_NOTIFIER_APP` environment variable if you install it somewhere else.

## Testing

```bash
make test
```

Sends a test notification. Click it to verify iTerm2 comes to the front.

## Uninstall

```bash
make uninstall
```

Or selectively:

```bash
make uninstall-opencode
make uninstall-claude
```
