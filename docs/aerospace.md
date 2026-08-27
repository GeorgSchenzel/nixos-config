# AeroSpace (darwin)

Config: `modules/programs/aerospace.nix` · Apply: `darwin-rebuild switch --flake .#mbp` · Docs: <https://nikitabobko.github.io/AeroSpace/guide>

All binds use **⌃⌥** (ctrl+alt), not plain ⌥ — on the German layout ⌥ composes special characters (`@ [ ] { } | € ~` …), and AeroSpace binds are global hotkeys that would swallow those combos system-wide.

## Windows

| Keys | Action |
|---|---|
| ⌃⌥ h/j/k/l | focus left/down/up/right |
| ⌃⌥⇧ h/j/k/l | move window |
| ⌃⌥ß / ⌃⌥´ | resize smaller / bigger |
| ⌃⌥⇧ h/j/k/l (service) | join with neighbor |

## Workspaces

| Keys | Action |
|---|---|
| ⌃⌥ 1–9, a–z | switch to workspace |
| ⌃⌥⇧ 1–9, a–z | move window there |
| ⌃⌥Tab | current ↔ previous workspace |
| ⌃⌥⇧Tab | move workspace to next monitor |

## Layouts

| Keys | Action |
|---|---|
| ⌃⌥- | tiles (side by side) |
| ⌃⌥, | accordion (stacked, padding strips peek) |

Windows nearly fullscreen + slightly overlapped = accordion. Press ⌃⌥- to fix.

## Service mode

Enter ⌃⌥⇧ö, actions auto-exit:

| Key | Action |
|---|---|
| f | toggle floating ↔ tiling |
| r | reset workspace tree |
| backspace | close all windows but current |
| esc | reload config |

Note: floating (`f`) ≠ accordion (⌥,) — different axes.

## How it works

- Workspaces are virtual — all on one native Space. Use exactly one native Space per monitor; ignore macOS Spaces & gestures (no swipe support).
- Every workspace belongs to a monitor (default: main display). Switching shows it there.
- Unplugging a monitor: its windows reassign to the remaining one.
- ⌘Tab works normally.
- System defaults (via nix): separate Spaces per display **off** (logout required once), group windows by app **on**.
- Ghostty tabs = macOS native tabs, which AeroSpace treats as separate windows (known bug: nikitabobko/AeroSpace#68). Workaround: `on-window-detected` forces `layout tiling` for Ghostty (see <https://ghostty.org/docs/help/macos-tiling-wms>). If tabs still confuse the layout, switch that rule to `layout floating` or prefer splits/accordion over tabs.

## Rebuilds & session restore

AeroSpace keeps the window→workspace tree only in memory (nikitabobko/AeroSpace#57). `darwin-rebuild switch` restarts the agent when its config changes, which would dump every window into workspace 1. Two hooks fix that:

- **save** — activation script (`extraActivation`) snapshots `aerospace list-windows --all` to `~/.aerospace-windows.tsv` *before* the agent reloads.
- **restore** — `after-startup-command` sleeps 1s and replays `move-node-to-workspace --window-id` per line.

Limitations: window-ids don't survive app restarts or reboots — stale ids simply fail silently (restore is a no-op then, like after a fresh login). Unrelated rebuilds don't restart the agent at all (plist unchanged).

Want swipe gestures anyway (BetterTouchTool):

```sh
aerospace list-workspaces --monitor focused --empty no | aerospace workspace --stdin next  # or prev
```

## CLI

```sh
aerospace list-windows --all --format '%{workspace}|%{app-name}|%{window-title}'
aerospace layout --workspace 1 --root tiles   # fix accidental accordion
aerospace list-workspaces --monitor focused --empty no
aerospace reload-config
```

## Appendix: why some keys look odd

AeroSpace binds QWERTY physical positions, no qwertz preset. So: ⌃⌥⇧**ö**=service mode, ⌃⌥**ß**=resize−, ⌃⌥**´**=resize+, ⌃⌥**-**(hyphen key)=tiles, ⌃⌥**,**=accordion; and ⌃⌥y/⌃⌥z hit the keys printing **Z**/**Y**.
