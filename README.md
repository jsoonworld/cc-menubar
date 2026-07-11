<div align="center">

# cc-menubar

**A native macOS menu bar app that keeps your Claude Code spend — and your [teamclaude](https://github.com/jung-wan-kim/teamclaude) account rotation — one glance away.**

![platform](https://img.shields.io/badge/platform-macOS%2013%2B-black?logo=apple)
![arch](https://img.shields.io/badge/arch-Apple%20Silicon-orange)
![language](https://img.shields.io/badge/Swift-single%20binary-F05138?logo=swift&logoColor=white)
![license](https://img.shields.io/badge/license-MIT-green)

<img src="docs/menubar.png" alt="cc-menubar in the macOS menu bar" width="520">

</div>

---

## What it is

`cc-menubar` is a tiny, dependency-light Swift status-bar app. It reads your local
[**ccusage**](https://github.com/ryoppippi/ccusage) data and (optionally) your
[**teamclaude**](https://github.com/jung-wan-kim/teamclaude) proxy status, then renders
both in the menu bar and a rich dropdown — so you always know **what you're spending**
and **which account is serving your requests**.

No dashboards to open, no browser tab. Just the menu bar.

## Screenshots

<img src="docs/menubar.png" alt="cc-menubar status item: pulse dot, spend sparkline, and top-cost model" width="520">

> The menu bar rolls through today / this-week / this-month / all-time cost, total
> tokens, parallel-session count, and your top-cost model (`Fable 5` above) — with a
> live pulse dot (green = a Claude Code session is active) and a mini spend sparkline.
> Click it to open the dropdown: a 14-day spend chart, per-model cost breakdown, and
> the teamclaude account-health panel.

## Features

- **💸 Cost & tokens at a glance** — today, this week, this month, and all-time,
  in USD **and** KRW, sourced from `ccusage` (offline, no network).
- **📈 14-day spend chart** in the dropdown, plus a per-model cost breakdown
  (Claude *and* Codex / GPT models are tracked side by side).
- **🟢 Live-session pulse** — the dot breathes green while a Claude Code session
  is writing to `~/.claude/projects`, grey when idle.
- **🔀 teamclaude health** *(optional)* — usable accounts `N/M`, Fable weekly-quota
  warnings, peak utilization, and the soonest quota reset, read straight from the
  local proxy's `/teamclaude/status`.
- **🧰 One-click actions** — add a Claude OAuth account or restart the teamclaude
  proxy right from the dropdown.
- **🪶 One Swift binary, zero runtime frameworks** — ~800 KB, no Electron, no menu-bar
  bloat. Runs as a login-item LaunchAgent.

## Requirements

- **macOS 13 (Ventura) or newer**, **Apple Silicon** (`arm64`). *Windows and Linux are
  not supported — this is a native AppKit menu-bar app.*
- **[ccusage](https://github.com/ryoppippi/ccusage)** reachable via `npx` (the app calls
  `npx ccusage … --json --offline`). Install Node.js / npm if you don't have it; `npx`
  fetches `ccusage` on first run.
- **Xcode Command Line Tools** to build (`xcode-select --install`) — provides `swiftc`.
- *(Optional)* **[teamclaude](https://github.com/jung-wan-kim/teamclaude)** running locally
  on port `3456` if you want the account-rotation panel. Without it, the app simply shows
  the cost/usage half.

> **Note:** the in-app UI labels are currently in Korean. Localization PRs are welcome.

## Install

```bash
git clone https://github.com/sangrokjung/cc-menubar.git
cd cc-menubar

# 1. build the binary (swiftc, ~a few seconds)
bash build.sh

# 2. install as a login-item LaunchAgent (starts on login, restarts on crash)
bash install.sh
```

`install.sh` copies the binary to `~/Applications/cc-menubar/`, writes a LaunchAgent
plist to `~/Library/LaunchAgents/`, and loads it. The ⚡ icon appears in your menu bar.

> **Unsigned app note.** cc-menubar isn't signed with an Apple Developer certificate,
> so Gatekeeper may complain the first time. `install.sh` strips the quarantine flag for
> you; if macOS still blocks it, run
> `xattr -d com.apple.quarantine ~/Applications/cc-menubar/cc-menubar`
> or allow it under **System Settings → Privacy & Security → Open Anyway**.

### Run without installing

```bash
bash build.sh
./.build/cc-menubar &
```

## Configuration

Everything works out of the box. One optional environment variable tunes the
teamclaude restart action:

| Variable | Purpose |
|---|---|
| `TEAMCLAUDE_LAUNCHD_LABEL` | If you run the teamclaude proxy under `launchd`, set this to its label (e.g. `com.example.teamclaude`) so the **Restart** button can `launchctl kickstart` it. When unset, cc-menubar restarts the proxy with `teamclaude restart`. |

Add it under `EnvironmentVariables` in the LaunchAgent plist, or export it before
launching manually.

## How it works

- **Usage** comes from `npx ccusage <daily|weekly|monthly> --json --offline`. cc-menubar
  probes common absolute `npx` paths first (so it works under `launchd`, where `.zshrc`
  isn't sourced), then falls back to `PATH`. All parsing is local; nothing is uploaded.
- **teamclaude health** is a plain `GET http://127.0.0.1:3456/teamclaude/status`. Only
  aggregate counts (active/usable accounts, quota utilization) are read — **no account
  emails or tokens are ever displayed or logged.**
- The whole thing is a single `NSStatusItem` + a custom-drawn `NSMenu`. State refreshes on
  a timer and when a Claude Code project directory changes.

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/io.github.sangrokjung.cc-menubar.plist
rm ~/Library/LaunchAgents/io.github.sangrokjung.cc-menubar.plist
rm -rf ~/Applications/cc-menubar
```

## Credits

- **[teamclaude](https://github.com/jung-wan-kim/teamclaude)** by jung-wan-kim — the
  multi-account Claude proxy this app visualizes. cc-menubar's account-health panel is
  built for it.
- **[ccusage](https://github.com/ryoppippi/ccusage)** by ryoppippi — the Claude Code
  usage/cost data source.

## License

[MIT](LICENSE) © 2026 sangrokjung
