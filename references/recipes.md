# Recipes

These examples use the script API. Prefer these patterns before writing
AppleScript directly.

## Real-Terminal CLI Smoke Test

```bash
id=$(scripts/gt-open --cwd "$PWD" --name "gt: smoke")
if scripts/gt-run "$id" "npm test"; then
  scripts/gt-close "$id"
else
  scripts/gt-screen "$id" > /tmp/gt-smoke-screen.txt
  scripts/gt-close "$id"
  exit 1
fi
```

## TUI Regression Check

```bash
id=$(scripts/gt-open --cwd "$PWD" --cmd "lazygit" --name "gt: lazygit")
scripts/gt-wait "$id" --for "Status" --timeout 20
scripts/gt-send "$id" --key arrowDown --key enter
scripts/gt-wait "$id" --screen        # settle, then print the frame
scripts/gt-send "$id" --key q
scripts/gt-close "$id"
```

If text capture is not enough to understand state:

```bash
scripts/gt-shot "$id" /tmp/gt-lazygit.png
```

## Prompt-Bar Automation

Prompt bars often treat pasted newlines as text. Submit with a real Enter key.

```bash
id=$(scripts/gt-open --cwd "$PWD" --cmd "claude" --name "gt: claude")
scripts/gt-wait "$id" --for ">"
scripts/gt-send "$id" --text "summarize this repo" --enter
```

## Dev Server Plus Agent Pane

```bash
id=$(scripts/gt-open --cwd "$PWD" --name "gt: app")
server=$(scripts/gt-split "$id" right --cmd "npm run dev" --title "gt: server")
scripts/gt-focus "$id"
scripts/gt-send "$id" --text $'claude\n'
```

## Screenshot Verification

```bash
id=$(scripts/gt-open --cwd "$PWD" --cmd "python -m textual run app.py" --name "gt: textual")
scripts/gt-wait "$id" --timeout 5
png=$(scripts/gt-shot "$id" /tmp/gt-ui.png)
printf '%s\n' "$png"
```

## Timeout Recovery

```bash
id=$(scripts/gt-open --cwd "$PWD" --name "gt: timeout")
if ! scripts/gt-run "$id" "long-running-command" --timeout 10; then
  scripts/gt-screen "$id" > /tmp/gt-timeout-screen.txt
  scripts/gt-shot "$id" /tmp/gt-timeout.png || true
fi
scripts/gt-close "$id"
```

## Multi-Agent Workspace

```bash
root=$(scripts/gt-open --cwd "$PWD" --name "gt: coordinator")
logs=$(scripts/gt-split "$root" right --cmd "tail -f logs/app.log" --title "gt: logs")
tests=$(scripts/gt-open "$root" --cwd "$PWD" --name "gt: tests")
scripts/gt-run "$tests" "npm test"
scripts/gt-focus "$root"
```
