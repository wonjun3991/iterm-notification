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
