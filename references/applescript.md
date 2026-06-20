# AppleScript Escape Hatch

Use this reference only when the `gt-*` scripts do not expose the action you
need. Keep any new reusable behavior in scripts so other agents can build on it.

## Requirements

Ghostty scripting is macOS-only and is reached through `osascript`.
Feature-probe instead of version-gating:

```bash
osascript -e 'tell application "Ghostty" to new surface configuration' >/dev/null 2>&1 \
  && echo "Ghostty scripting OK" || echo "Ghostty scripting NOT available"
```

## Object Hierarchy

```
application -> windows -> tabs -> terminals
```

- Window: `id`, `name`, `selected tab`
- Tab: `id`, `name`, `index`, `selected`, `focused terminal`
- Terminal: `id`, `name`, `working directory`

## Surface Configuration

```applescript
tell application "Ghostty"
    set conf to new surface configuration
    set font size of conf to 14
    set initial working directory of conf to "/path/to/project"
    set command of conf to "/bin/zsh"
    set initial input of conf to "echo hello\n"
    set wait after command of conf to true
    set environment variables of conf to {"FOO=bar", "BAZ=qux"}
end tell
```

## Common Operations

Create a tab:

```applescript
tell application "Ghostty"
    set conf to new surface configuration
    set initial working directory of conf to "/path/to/project"
    set tb to new tab in front window with configuration conf
    set t to focused terminal of tb
    perform action "set_tab_title:gt: task" on t
    return id of t
end tell
```

Split a terminal:

```applescript
tell application "Ghostty"
    set t to terminal id "TERMINAL_ID"
    set conf to new surface configuration
    set initial working directory of conf to "/path/to/project"
    split t direction right with configuration conf
    return id of (focused terminal of selected tab of front window)
end tell
```

Send text and submit:

```applescript
tell application "Ghostty"
    set t to terminal id "TERMINAL_ID"
    input text "npm test" to t
    send key "enter" to t
end tell
```

`input text` is bracketed paste, not typing. A pasted newline does not submit a
prompt. Send a real Enter key when the command should run.

Send a modified key:

```applescript
send key "c" modifiers "control" to t
```

Modifiers are a comma-separated string such as `"control,shift"`.

Focus:

```applescript
focus t
```

Close a terminal:

```applescript
close (terminal id "TERMINAL_ID")
```

## Actions

```applescript
perform action "goto_split:right" on t
perform action "resize_split:right,10" on t
perform action "equalize_splits" on t
perform action "next_tab" on t
perform action "previous_tab" on t
perform action "set_tab_title:My Tab" on t
perform action "set_surface_title:My Surface" on t
perform action "toggle_split_zoom" on t
```

For the full action list, see [actions.md](actions.md).

## Execution

Run multi-line scripts with stdin:

```bash
osascript <<'EOF'
tell application "Ghostty"
    set conf to new surface configuration
    set initial working directory of conf to "/path/to/project"
    new tab in front window with configuration conf
end tell
EOF
```

Or run a single expression:

```bash
osascript -e 'tell application "Ghostty" to get version'
```
