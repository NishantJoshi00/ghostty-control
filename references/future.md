# Future Work

These are intentionally documented, not implemented. The current priority is to
keep the `gt-*` contract small, reliable, and easy for agents to compose.

## Reusable Helpers

Add helpers only after the underlying command pattern repeats enough to justify
another public script.

Candidate helpers:

- `gt-capture-failure`: save `gt-screen` text and best-effort `gt-shot` image for
  a terminal id.
- `gt-open-run-close`: open a named tab, run one command, capture failure
  evidence, and close on success.
- `gt-tui-check`: open a TUI command, wait for an initial pattern, send a small
  key sequence, and capture the final state.

Avoid a large workspace DSL until there are several proven recipes that cannot
be expressed cleanly with `gt-open`, `gt-split`, `gt-run`, `gt-wait`, and
`gt-close`.

## Alternate Backends

AppleScript remains the real Ghostty backend. Future backends should implement
the same script-level contract rather than exposing a separate API.

Candidates:

- `tmux`: useful for CI/headless deterministic sessions, but not real Ghostty
  rendering.
- PTY: useful for non-visual command automation, but weaker for TUI perception.
- `libghostty` or another Ghostty-native surface if it becomes practical for
  headless terminal state.

Backend work should wait until JSON shapes and exit-code behavior are stable.
