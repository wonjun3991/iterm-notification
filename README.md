# iterm-notification

iTerm2 native notifications for AI coding tools. Get notified when your AI finishes a task or needs your attention — with the iTerm icon, not Script Editor.

## How It Works

Uses [iTerm2 OSC 9](https://iterm2.com/documentation-escape-codes.html) escape sequences to trigger native notifications. No app bundle, no build step — just shell scripts and a JS plugin.

```
AI tool finishes / asks question
        |
        | printf '\e]9;message\a' > /dev/tty
        v
iTerm2 shows native notification (iTerm icon)
```

## Supported Tools

| Tool | Integration | Triggers |
|------|-------------|----------|
| [Claude Code](https://claude.ai/code) | Shell hooks (`hooks/claude-code/`) | Task complete, needs attention |
| [OpenCode](https://opencode.ai) | Plugin (`plugin/notification.js`) | Task complete, question asked, permission needed |

## Quick Setup

**Give this URL to your AI assistant and ask it to set up notifications:**

```
https://raw.githubusercontent.com/wonjun3991/iterm-notification/main/SETUP.md
```

Or install manually:

### Claude Code

```bash
make install-claude
```

Then add hooks to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/stop-notify.sh" }] }
    ],
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  }
}
```

### OpenCode

```bash
make install-opencode
```

Then register `notification.js` in your OpenCode plugins config.

## Requirements

- macOS + iTerm2
- `jq` (Claude Code hooks only): `brew install jq`

## Test

```bash
make test
```

## Uninstall

```bash
make uninstall          # both
make uninstall-claude   # Claude Code only
make uninstall-opencode # OpenCode only
```
