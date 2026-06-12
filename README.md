# ghostty-control

An agent skill for controlling the [Ghostty](https://ghostty.org) terminal via AppleScript — and for testing CLIs and TUIs inside a real terminal. macOS only.

Think browser automation, but for the terminal: act → wait → perceive → assert. The agent opens a tab, runs commands or drives a TUI, reads the rendered screen back (as text or as a screenshot), and asserts on what it sees.

## Install

```bash
npx skills add NishantJoshi00/ghostty-control
```

## Requirements

- macOS
- A recent Ghostty **tip/nightly** build (the AppleScript scripting API is a preview feature, not in v1.2.x stable)
- Accessibility + Screen Recording permissions for screenshots (`gt-shot`)

Verify scripting is available:

```bash
osascript -e 'tell application "Ghostty" to new surface configuration' >/dev/null 2>&1 \
  && echo OK || echo "scripting not available"
```

## What's inside

- **`SKILL.md`** — the AppleScript dictionary in practice: windows, tabs, splits, surface configurations, key/text/mouse input, workspace patterns.
- **`references/automation.md`** — the testing cheatsheet: verified capture semantics, key-name reference, anti-flake practices, and every caveat we hit while exercising the kit against real programs (neovim, less, python, a ratatui app).
- **`references/actions.md`** — complete `perform action` string reference.
- **`scripts/`** — ten standalone zsh tools (no harness assumptions; work for any agent or human):

| Script | Does |
|--------|------|
| `gt-open` | named tab, prints the terminal id (the handle everything else takes) |
| `gt-run` | run a command, block until it finishes, print the screen, propagate exit code |
| `gt-send` | keystrokes, text, raw input (`--raw` for kitty-protocol apps like neovim) |
| `gt-wait` | block until a pattern renders, or until the screen settles |
| `gt-screen` | rendered screen as text |
| `gt-shot` | terminal window as PNG (tab-targeted with an id) |
| `gt-mouse` | click, move, scroll |
| `gt-copy` / `gt-paste` | clipboard in and out, user's clipboard restored |
| `gt-close` | dialog-free teardown (graceful exit, forced fallback auto-confirms the sheet) |

A session:

```bash
id=$(scripts/gt-open --cwd ~/repo --name "gt: tests")
scripts/gt-run "$id" "cargo test" && echo passed
scripts/gt-close "$id"
```

## Provenance

Every command, key name, and caveat in here was verified against a live Ghostty — including a full exercise where an agent wrote, built, and chatted with a ratatui app, editing the source through neovim driven entirely over this kit.

## License

MIT
