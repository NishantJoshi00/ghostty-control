# Ghostty Action Reference

Complete list of action strings for use with `perform action "ACTION" on term`.

## Table of Contents

- [Splits and Windows](#splits-and-windows)
- [Tabs](#tabs)
- [Titles](#titles)
- [Scrolling](#scrolling)
- [Font](#font)
- [Clipboard](#clipboard)
- [Search](#search)
- [Toggles](#toggles)
- [Selection](#selection)
- [Terminal Control](#terminal-control)
- [Close](#close)
- [Undo/Redo](#undoredo)
- [Input](#input)
- [Config](#config)

## Splits and Windows

| Action | Description |
|--------|-------------|
| `new_window` | Open new window |
| `new_split:right` | Split right |
| `new_split:down` | Split down |
| `new_split:left` | Split left |
| `new_split:up` | Split up |
| `new_split:auto` | Split auto (Ghostty chooses direction) |
| `goto_split:right` | Focus split to the right |
| `goto_split:left` | Focus split to the left |
| `goto_split:up` | Focus split above |
| `goto_split:down` | Focus split below |
| `goto_split:previous` | Focus previous split |
| `goto_split:next` | Focus next split |
| `resize_split:right,N` | Grow split rightward by N cells |
| `resize_split:left,N` | Grow split leftward by N cells |
| `resize_split:up,N` | Grow split upward by N cells |
| `resize_split:down,N` | Grow split downward by N cells |
| `equalize_splits` | Make all splits equal size |
| `toggle_split_zoom` | Zoom/unzoom current split |
| `toggle_fullscreen` | Toggle native fullscreen |
| `toggle_window_float_on_top` | Float window on top (macOS) |
| `reset_window_size` | Restore default window size (macOS) |
| `goto_window:previous` | Focus previous window |
| `goto_window:next` | Focus next window |

## Tabs

| Action | Description |
|--------|-------------|
| `new_tab` | Create new tab |
| `goto_tab:N` | Go to tab N (1-indexed) |
| `next_tab` | Next tab |
| `previous_tab` | Previous tab |
| `last_tab` | Last tab |
| `move_tab:N` | Move tab by N positions (negative = left) |

## Titles

| Action | Description |
|--------|-------------|
| `set_tab_title:TEXT` | Set tab title |
| `set_surface_title:TEXT` | Set window/surface title |
| `prompt_tab_title` | Prompt user for tab title |
| `prompt_surface_title` | Prompt user for window title |

## Scrolling

| Action | Description |
|--------|-------------|
| `scroll_to_top` | Scroll to top |
| `scroll_to_bottom` | Scroll to bottom |
| `scroll_page_up` | Scroll one page up |
| `scroll_page_down` | Scroll one page down |
| `scroll_page_fractional:F` | Scroll by fraction (e.g., 0.5) |
| `scroll_page_lines:N` | Scroll by N lines |
| `scroll_to_selection` | Scroll to current selection |
| `scroll_to_row:N` | Scroll to row N |

## Font

| Action | Description |
|--------|-------------|
| `increase_font_size:N` | Increase font size by N |
| `decrease_font_size:N` | Decrease font size by N |
| `reset_font_size` | Reset to default size |
| `set_font_size:N` | Set font size to N |

## Clipboard

| Action | Description |
|--------|-------------|
| `copy_to_clipboard` | Copy selection to clipboard |
| `paste_from_clipboard` | Paste clipboard contents |
| `paste_from_selection` | Paste selection clipboard |
| `copy_url_to_clipboard` | Copy URL under cursor |
| `copy_title_to_clipboard` | Copy window title |

## Search

| Action | Description |
|--------|-------------|
| `start_search` | Open search UI |
| `end_search` | Close search UI |

## Toggles

| Action | Description |
|--------|-------------|
| `toggle_fullscreen` | Fullscreen mode |
| `toggle_split_zoom` | Zoom current pane |
| `toggle_window_float_on_top` | Float on top (macOS) |
| `toggle_readonly` | Disable terminal input |
| `toggle_mouse_reporting` | Toggle mouse capture |
| `toggle_secure_input` | Prevent keyboard monitoring (macOS) |
| `toggle_quick_terminal` | Show/hide dropdown terminal |
| `toggle_visibility` | Show/hide all windows (macOS) |
| `toggle_background_opacity` | Toggle transparency (macOS) |

## Selection

| Action | Description |
|--------|-------------|
| `select_all` | Select all text |
| `adjust_selection:left` | Extend selection left |
| `adjust_selection:right` | Extend selection right |
| `adjust_selection:up` | Extend selection up |
| `adjust_selection:down` | Extend selection down |

## Terminal Control

| Action | Description |
|--------|-------------|
| `reset` | Reset terminal to initial state |
| `clear_screen` | Clear screen and scrollback |
| `jump_to_prompt` | Navigate shell prompts (needs shell integration) |
| `write_scrollback_file:copy` | Export scrollback to clipboard |
| `write_screen_file:copy` | Export screen to clipboard |

## Close

| Action | Description |
|--------|-------------|
| `close_surface` | Close current terminal |
| `close_tab` | Close current tab |
| `close_window` | Close current window |

## Undo/Redo

| Action | Description |
|--------|-------------|
| `undo` | Restore recently closed tab/split/window (macOS) |
| `redo` | Reopen closed element (macOS) |

## Input

| Action | Description |
|--------|-------------|
| `text:STRING` | Send text (Zig string syntax) |
| `csi:SEQUENCE` | Send CSI escape sequence |
| `esc:SEQUENCE` | Send ESC sequence |

## Config

| Action | Description |
|--------|-------------|
| `open_config` | Open config file in editor |
| `reload_config` | Reload configuration |
| `inspector:toggle` | Toggle terminal inspector |
