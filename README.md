# ghostty-control

[![skills.sh](https://skills.sh/b/NishantJoshi00/ghostty-control)](https://skills.sh/NishantJoshi00/ghostty-control)

Browser use, but for terminals. Agents open named Ghostty tabs, run commands,
drive TUIs, wait for rendered output, and read the screen back as text or as a
screenshot.

The public interface is the `scripts/gt-*` command set. AppleScript is the
macOS backend.

## Install

```bash
npx skills add NishantJoshi00/ghostty-control
```

## Requirements

- macOS
- Ghostty with AppleScript scripting enabled
- Accessibility and Screen Recording permissions for screenshot flows

Preflight:

```bash
scripts/gt-probe
scripts/gt-probe --json
```

## Quick Use

```bash
id=$(scripts/gt-open --cwd "$PWD" --name "gt: tests")
scripts/gt-run "$id" "cargo test"
scripts/gt-close "$id"
```

The loop is:

```text
probe -> open/attach -> act -> wait -> perceive -> decide -> clean up
```

## Tests

Tests use ShellSpec and drive real Ghostty. They open temporary tabs named
`gt: test ...`; each example tracks the exact ids it opens and closes only
those ids.

```bash
shellspec
shellspec tests/unit
shellspec tests/integration
shellspec tests/regression
```

## Scripts

| Script | Does |
|--------|------|
| `gt-probe` | preflight macOS, `osascript`, Ghostty scripting, clipboard, screenshot command |
| `gt-open` | open a named tab, print the terminal id |
| `gt-list` | list Ghostty terminals |
| `gt-status` | validate and inspect one terminal id |
| `gt-run` | run a command, block until it finishes, print the screen, propagate exit code |
| `gt-send` | keystrokes, text, raw input, stdin blocks |
| `gt-wait` | block until a pattern renders, or until the screen settles |
| `gt-screen` | rendered screen as text |
| `gt-shot` | terminal window as PNG |
| `gt-focus` | focus a terminal by id |
| `gt-split` | create a split from a terminal by id |
| `gt-action` | constrained Ghostty actions such as tab/split navigation and titles |
| `gt-mouse` | click, move, scroll |
| `gt-copy` / `gt-paste` | clipboard in and out, user's clipboard restored |
| `gt-close` | dialog-free teardown |

JSON is available for machine-readable flows: `gt-probe`, `gt-open`, `gt-list`,
`gt-status`, `gt-run`, `gt-wait`, `gt-screen`, `gt-split`, and `gt-close`.

## References

- `SKILL.md`: script-first operating manual for agents.
- `references/api-contract.md`: stable command behavior for people building on
  this skill.
- `references/recipes.md`: script-first workflow examples.
- `references/automation.md`: verified TUI automation practices.
- `references/applescript.md`: direct AppleScript escape hatch.
- `references/actions.md`: Ghostty action string reference.
- `references/future.md`: documented ideas for future helpers and alternate
  backends.

## Provenance

The original command set and caveats were verified against a live Ghostty. New
script changes should be checked with `zsh -n scripts/gt-*` plus a live smoke
test when Ghostty is available.

## License

MIT
