# TUI Testing Cheatsheet

Drive a TUI in a real Ghostty tab, see what it renders, assert on it. The loop is the same as browser automation: **act → wait → perceive → assert**.

Everything in this file was verified against a live Ghostty nightly. For the exhaustive action list see [actions.md](actions.md); this file is the subset that matters for testing, plus the practices that keep it from flaking.

## The Loop

```
open named tab → run TUI → wait for paint → send keys → wait → capture screen → assert → teardown
```

Scripts in [`../scripts/`](../scripts/) package each step (see [Scripts](#scripts) below).

## Core Actions (90% of testing)

### Act

```applescript
input text "npm test" to term                -- bracketed PASTE; a pasted \n does NOT submit
send key "enter" to term                     -- real Enter submits the pasted line
send key "down" to term                      -- single keystroke, real key event
send key "c" modifiers "control" to term     -- modifiers = comma-separated STRING
```

Raw `input text` is paste, not typing: append `send key "enter"` to run the line. The
`gt-send`/`gt-run` scripts fold this in -- a trailing newline in `--text`/`--stdin` is sent
as a real Enter, so `gt-send <id> --text $'npm test\n'` runs the command.

Key names are camelCase `Ghostty.Input.Key` raw values (verified against source and live):
`a`-`z`, `digit0`-`digit9`, `enter`, `escape`, `backspace`, `delete`, `tab`, `space`, `home`, `end`, `insert`, `pageUp`, `pageDown`, `arrowUp`, `arrowDown`, `arrowLeft`, `arrowRight`, `f1`-`f24`, `comma`, `period`, `slash`, `backslash`, `semicolon`, `quote`, `backquote`, `minus`, `equal`, `bracketLeft`, `bracketRight`, `numpad0`-`numpad9`, `numpadEnter`. Wrong forms that look right: `up`, `down`, `esc`, `return`, `arrow_down`, `G` — all rejected. No uppercase letters; shifted printables go via `input text`.
Modifiers: `"shift"`, `"control"`, `"option"`, `"command"`, combined as `"control,shift"`.

### Perceive (text)

```applescript
perform action "write_screen_file:copy" on term       -- current rendered screen
perform action "write_scrollback_file:copy" on term   -- full history
```

**`:copy` puts a temp-file PATH on the clipboard, not the contents.** Read it back:

```bash
osascript -e '...write_screen_file:copy...' && sleep 0.3 && cat "$(pbpaste)"
```

### Perceive (image)

No AppleScript route; use `screencapture` with the window's accessibility bounds:

```bash
# Ghostty's real terminal window is the AXStandardWindow; the AXUnknown
# entries at 0,0 are menu-bar artifacts -- filter them out.
osascript -e 'tell application "System Events" to tell process "Ghostty" to get {position, size} of (first window whose subrole is "AXStandardWindow")'
screencapture -x -R"x,y,w,h" /tmp/shot.png
```

Window must be on screen and unobscured. Text capture has no such constraint — prefer text unless you need colors, layout, or rendering itself.

**Escalation rule:** if `gt-screen` output is ambiguous or unreadable — TUI mid-transition, complex box-drawing layout, overlapping panels, or you cannot confidently answer "what is the TUI showing right now?" — reach for `gt-shot <id> out.png` before acting. Use what you see in the image, not what you expected to see.

### Manage

```applescript
set tb to new tab in front window with configuration (new surface configuration)
perform action "set_tab_title:test: <what>" on term    -- name it FIRST
set t to terminal id "UUID"                            -- stable handle, survives title changes
close tab tb
```

## Occasional

| Action | Use |
|--------|-----|
| `scroll_to_bottom` / `scroll_to_top` | reposition before capture |
| `clear_screen` | clean slate between cases (clears scrollback too) |
| `reset` | TUI left the terminal in a bad state |
| `toggle_split_zoom` | maximize one pane before an image capture |
| `goto_split:right` etc. | move focus across panes |

Everything else: [actions.md](actions.md).

## Practices

1. **Named tab in the current window, never a new window.** Name it first (`set_tab_title:test: ...`), then run. A failed scripted close on a separate window can strand a surface and crack the render.
2. **Wait for the shell before typing.** A fresh tab needs 1-2s of shell init; `input text` sent too early is silently dropped — the command never runs and the tab sits idle looking like a mystery. `delay 2` between `new tab` and the first `input text`.
3. **Delays go inside the AppleScript block, not bash sleeps between osascript calls.** One process, object references stay alive, no re-resolving terminals between steps:

   ```applescript
   tell application "Ghostty"
       set tb to new tab in front window with configuration (new surface configuration)
       set t to focused terminal of tb
       perform action "set_tab_title:test: build" on t
       delay 2
       input text "make test" to t
       send key "enter" to t
   end tell
   ```
4. **Target by stable id, not focus.** `terminal id "UUID"` keeps working when the TUI retitles the tab or focus drifts. Capture the id at open time; pass it everywhere.
5. **Never fixed sleeps for output — settle or wait-for-text.** TUIs repaint async. Either poll the screen until a pattern appears, or capture twice and proceed when two consecutive frames match.
6. **`input text` is paste, `send key` is typing.** Bracketed paste reaches many TUIs as a paste event, not keystrokes. Driving menus, lists, and keybindings needs `send key`.
7. **Save and restore the clipboard.** Both capture actions clobber it. `pbpaste` before, `pbcopy` after.
8. **Quit the TUI before closing the tab.** Send `q` or ctrl-c first; killing the tab under a running TUI is how terminals get left in weird states.
9. **Guarded teardown.** Before `close tab`, verify its name still starts with your test prefix. If it doesn't, you're about to close someone's real work — abort and report instead.
10. **Collect, then close.** Closing a tab while iterating `repeat with tb in tabs` invalidates the indices mid-loop. Gather references into a list first, then close them in a second pass.
11. **On failure, keep the evidence.** Save the last captured screen (text or PNG) before teardown; it's the TUI equivalent of a failure screenshot.
12. **If `gt-screen` is ambiguous, escalate to `gt-shot` before the next action.** Text strips color and collapses box-drawing; a TUI mid-transition or with overlapping elements can be unreadable. If you cannot determine state from text, take a screenshot first — then act on what you see, not on what you expected.
13. **Don't rely on terminal-set titles or `working directory` for discovery.** OSC title injection from inside a shell did not propagate to the AppleScript `name` property in testing, and `working directory` only reflects the config-set initial directory. The id you captured at creation is the only reliable handle.

The caller can be anything — Claude Code, another agent, a human, CI. Nothing here assumes a harness; it's plain zsh + `osascript`. Version detection without AppleScript: `$TERM_PROGRAM` is `ghostty` and `$TERM_PROGRAM_VERSION` carries a real semver (e.g. `1.3.2-main+e8fb7eaba`) in any shell Ghostty spawned.

## Scripts

Packaged in [`../scripts/`](../scripts/) so a session is one-liners instead of heredocs. All verified against a live Ghostty. `gt-open` prints the terminal id; the id is the handle every other script takes.

| Script | Step | Does |
|--------|------|------|
| `gt-probe [--json]` | preflight | check whether this host can use the skill |
| `gt-open [sibling_id] [--cwd d] [--cmd c] [--name n] [--json]` | open | named tab (in sibling's window if id given), prints terminal id |
| `gt-list [--json]` | discover | list visible Ghostty terminals |
| `gt-status <id> [--json]` | discover | validate one terminal id |
| `gt-run <id> "cmd" [--timeout N] [--json]` | act+wait | run command, block until done (sentinel), print screen, exit with cmd's code. Commands that exit ONLY — launch TUIs/pagers/REPLs via `gt-open --cmd` instead or gt-run stalls until timeout |
| `gt-send <id> --key SPEC / --text STR / --stdin / --enter` | act | keystrokes and text, in argument order |
| `gt-wait <id> [--for pat] [--timeout N] [--screen] [--json]` | wait | settle loop, or block until pattern renders; `--screen` prints the final frame (wait+perceive in one call); timeout dumps the last frame to stderr |
| `gt-screen <id> [--scrollback] [--json]` | perceive | screen as text on stdout |
| `gt-shot [out.png]` | perceive | front Ghostty window as PNG, prints path |
| `gt-focus <id>` | manage | focus a terminal by id |
| `gt-split <id> right|left|up|down [--cwd d] [--cmd c] [--title t] [--json]` | manage | create a split and print its terminal id |
| `gt-action <id> <verb> [args...]` | manage | constrained tab/split/title/reset actions |
| `gt-mouse <id> click x y / move x y / scroll dy` | act | mouse events (pixels, surface origin) |
| `gt-copy <id>` | perceive | terminal's selection to stdout |
| `gt-paste <id> [text]` | act | true clipboard-paste event (clipboard restored) |
| `gt-close <id> [--force] [--json]` | teardown | dialog-free close: interrupt + EOF first; falls back to forced close and auto-confirms Ghostty's "process is running" sheet |

CLI testing — `gt-run` covers most sessions alone:

```bash
id=$(gt-open --cwd ~/repo --name "gt: tests")
gt-run "$id" "npm test" && echo passed
gt-close "$id"
```

TUI driving — send/wait/screen:

```bash
id=$(gt-open --cwd ~/repo --cmd lazygit)
gt-wait "$id" --for "Status"
gt-send "$id" --key down --key enter
gt-wait "$id" --screen
gt-send "$id" --key q && gt-close "$id"
```

Hard-won caveats from live exercises driving real programs through this kit:

- **`send key` silently never arrives at kitty-keyboard-protocol apps (neovim 0.12+).** No error, no effect — keys work fine in zsh, less, python, then vanish in nvim. The fix is raw input: `perform action "text:..."` (Zig string syntax, `\r` enter, `\x1b` escape), packaged as `gt-send --raw`. Drive nvim entirely with it: `--raw ':%d\r'`, `--raw 'i'`, paste the body, `--raw '\x1b'`, `--raw ':wq\r'`. Likely a Ghostty preview-API bug worth reporting upstream.
- **`gt-shot` photographs the visible tab, not your target.** Pass the terminal id (`gt-shot <id> out.png`) and it selects the target's tab, shoots, and restores the user's selection (~0.7s of visible tab-flicker).
- **Stale nvim swap files block startup with a dialog** that eats your first keystrokes' meaning. Launch with `-n` (and `--clean`) when driving nvim under automation; clear `~/.local/state/nvim/swap/` if a prior session got killed.
- **Infer state from the screen, not from your last action.** Every wrong turn in the exercise came from assuming a keystroke landed. Capture (`gt-screen`/`gt-shot <id>`) after each state-changing step before sending the next.
- **On a prompt bar, a `\n` is not an Enter.** Multiline composers (Claude Code, REPLs) take a pasted newline as a literal newline, not a submit. Don't assume `\n` will behave like Enter — submit with a real Enter key (`send key "enter"`).

Program-specific setup that prevents automation flakes — launch interactive
tools with these when driving them:

| Program | Launch as | Why |
|---------|-----------|-----|
| python | `PYTHON_BASIC_REPL=1 python3` | the 3.13+ fancy REPL rewrites pasted input and breaks paste-driven automation |
| git | `git --no-pager …` or `GIT_PAGER=cat git …` | a pager swallows output and blocks the sentinel |
| any command needing only output | append `\| cat` | disables paging entirely; prefer `gt-run` on the piped form over driving `less` |
| gdb/lldb | `set pagination off` / `settings set term-width 0` | `--More--` prompts never settle and eat keys |
| nvim | `nvim -n --clean` | stale swap-file dialogs steal the first keystrokes; also see the `--raw` caveat above |

Input semantics learned the hard way:

- **Key names are lowercase.** `--key G` errors; shifted printable chars go via `--text "G"`. Ctrl chords (`--key u,control`) work and are verified functionally.
- **`input text` is bracketed paste: a pasted newline does not submit.** Interior newlines stack lines in the buffer; submitting needs a real Enter key. The scripts fold this in: a trailing newline in `gt-send --text`/`--stdin` is converted to a real Enter, so `gt-send <id> --text $'cmd\n'` runs `cmd`, and `cat snippet.py | gt-send <id> --stdin` pastes the indented python `def` then runs it (no `--enter` needed). Raw AppleScript `input text` does not do this: paste, then `send key "enter"` yourself.
- **Paste is async.** Restoring the clipboard too early pastes the old contents (gt-paste holds 0.8s before restoring).
