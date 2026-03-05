// OpenCode Notification Plugin - iTerm2 / Ghostty
// iTerm2: OpenCodeNotifier.app (UNUserNotification, 클릭 시 iTerm 포커스)
// Ghostty: OSC 777
import { writeFileSync } from "node:fs"
import { execSync } from "node:child_process"
import { dirname, join } from "node:path"
import { fileURLToPath } from "node:url"

export const NotificationPlugin = async ({ $ }) => {
  const termProgram = process.env.TERM_PROGRAM || ""
  const pluginDir = dirname(fileURLToPath(import.meta.url))
  const notifierApp = join(pluginDir, "OpenCodeNotifier.app")

  let ttyDevice = "/dev/tty"
  try {
    const tty = execSync(`ps -o tty= -p ${process.pid}`, { encoding: "utf-8" }).trim()
    if (tty && tty !== "??") ttyDevice = `/dev/${tty}`
  } catch {}

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
      try {
        execSync(`open "${notifierApp}" --args "${title}" "${message}"`, {
          stdio: "ignore",
        })
      } catch {}
    } else {
      await sendOsc(`777;notify;${title};${message}`)
    }
  }

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await notify("OpenCode", "Task completed")
      }
      if (event.type === "permission.asked") {
        await notify("OpenCode", "Needs your attention")
      }
    },
  }
}
