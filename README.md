<div align="center">

[English](README.md) | [한국어](README.ko.md) | [简体中文](README.zh-CN.md)

# cc-menubar

**Stop typing `ccusage` every time — it's just there in your menu bar.**

![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-blue)
![Arch](https://img.shields.io/badge/arch-Apple%20Silicon-black)
![Swift](https://img.shields.io/badge/Swift-single%20binary-orange)
![License](https://img.shields.io/badge/license-MIT-green)

<img src="docs/menubar.png" width="520">

</div>

## Screenshots

<p align="center">
  <img src="docs/menubar.png" width="520"><br>
  <sub>Menu bar — cost, tokens, parallel sessions, top model, a live pulse dot, and a spend sparkline</sub>
</p>

<p align="center">
  <img src="docs/dropdown.png" width="360"><br>
  <sub>Dropdown — live teamclaude account rotation (14 accounts) and Codex usage</sub>
</p>

## What it is

cc-menubar is a native macOS menu bar app for people who run Claude Code (and Codex) all day and keep wondering what it's actually costing them. Instead of opening a terminal and typing `ccusage`, today's, this week's, this month's, and all-time cost just sit in your menu bar — in USD and KRW.

The app itself is a single ~800KB Swift binary. No Electron, no background runtime, no npm install for the app.

## Features

- 💰 **Rotating cost summary** — today / this week / this month / all-time cost (USD + KRW), total tokens, parallel session count, and the priciest model, cycling right in the menu bar
- 💚 **Live pulse dot + spend sparkline** — a breathing green dot when a session is active, with an inline sparkline of recent spend
- 📈 **14-day spend chart** — the trend, not just a snapshot, in the dropdown
- 🧮 **Per-model cost breakdown** — Claude and Codex/GPT tracked side by side
- 🩺 **teamclaude account health** — accounts available (N/M), Fable weekly quota warnings, peak usage rate, next reset time
- ⚡ **One-click actions** — add a Claude OAuth account, restart the proxy

## Requirements

- macOS 13+
- **Apple Silicon (arm64) only** — Intel Macs, Windows, and Linux are not supported
- Xcode Command Line Tools (`swiftc`) to build
- Node.js / `npx`, used to call `ccusage` under the hood

## Install

```bash
git clone https://github.com/sangrokjung/cc-menubar.git
cd cc-menubar
bash build.sh
bash install.sh
```

`install.sh` registers a LaunchAgent: cc-menubar starts automatically at login and restarts itself if it crashes.

The app isn't code-signed, so macOS Gatekeeper may block the first launch (`install.sh` strips the quarantine flag for you). If it still complains:

```bash
xattr -d com.apple.quarantine ~/Applications/cc-menubar/cc-menubar
```

or open **System Settings → Privacy & Security** and click **Open Anyway**.

## Run without installing

Just want to try it once? Build and run the binary directly — no LaunchAgent, no auto-start at login:

```bash
git clone https://github.com/sangrokjung/cc-menubar.git
cd cc-menubar
bash build.sh
./.build/cc-menubar &
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `TEAMCLAUDE_LAUNCHD_LABEL` | *(unset)* | If you run teamclaude under launchd, set this to its label. The Restart button will then use `launchctl kickstart` for a clean restart; if unset, it falls back to running `teamclaude restart`. |

## How it works

Everything runs on your Mac, locally:

- Watches `~/.claude/projects` for changes to detect active sessions
- Calls `npx ccusage --json --offline` — the `--offline` flag means no network calls, nothing leaves your machine
- Optionally reads teamclaude's local status endpoint at `http://localhost:3456/teamclaude/status`

No email address, no API token, no personal data is ever shown or sent anywhere.

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/io.github.sangrokjung.cc-menubar.plist
rm ~/Library/LaunchAgents/io.github.sangrokjung.cc-menubar.plist
rm -rf ~/Applications/cc-menubar
```

## Credits

- [ccusage](https://github.com/ryoppippi/ccusage) by [ryoppippi](https://github.com/ryoppippi) — local Claude Code usage/cost data
- [teamclaude](https://github.com/jung-wan-kim/teamclaude) by [jung-wan-kim](https://github.com/jung-wan-kim) — local multi-account rotation proxy (optional)

App UI labels are currently in Korean — localization PRs are welcome.

## License

MIT © 2026 [sangrokjung](https://github.com/sangrokjung)
