# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal tmux config (not a build system, no tests, no package manager). All changes take effect via `tmux source-file ~/.tmux/tmux.conf` or prefix + `Enter`.

## Key commands

```bash
# Reload config in running server
tmux source-file ~/.tmux/tmux.conf

# Install/update plugins via TPM
~/.tmux/plugins/tpm/bin/install_plugins
~/.tmux/plugins/tpm/bin/update_plugins all
~/.tmux/plugins/tpm/bin/clean_plugins

# Test a save/restore cycle manually
~/.tmux/plugins/tmux-resurrect/scripts/save.sh
~/.tmux/plugins/tmux-resurrect/scripts/restore.sh

# Verify resurrect save file integrity (no corrupted dir fields)
d="$HOME/.local/share/tmux/resurrect"; f="$(readlink "$d/last")"
awk -F'\t' '/^pane/ && $8 !~ /^:\//{print "BROKEN", $2, $8}' "$d/$f"
```

## Architecture

Single config entrypoint: `tmux.conf` → loaded on server start, reloaded via TPM at the bottom (`run '~/.tmux/plugins/tpm/tpm'`). Remote sessions auto-source `tmux.remote.conf` (detected via `$SSH_CLIENT`).

**Helper scripts:**
- `yank.sh` — clipboard backend selector; called by copy-mode bindings. Resolves pbcopy → reattach-to-user-namespace → xsel/xclip → remote tunnel → OSC 52.
- `renew_env.sh` — refreshes env vars in all idle shell panes after re-attach (bound to prefix + `$`).

**Plugin layer (TPM):** Plugins live in `~/.tmux/plugins/`, managed by TPM. All plugin options (`@plugin-name-option`) must be set BEFORE the `run '...tpm/tpm'` line.

**Resurrect/Continuum save format:** Tab-delimited, 11 fields per pane line:
`pane | session | win# | win_active | win_flags | pane_index | pane_title | :dir | pane_active | pane_command | :full_command`

There is a known upstream bug: empty `#{pane_title}` causes bash `read` to collapse the dir field to `1`. This is mitigated by `@resurrect-hook-post-save-all` in `tmux.conf` which repairs any collapsed lines in the just-written save file. **Do not remove this hook.** Save files live at `~/.local/share/tmux/resurrect/`; `last` is a relative symlink to the most recent.

**Prefix key:** `C-a` (not the default `C-b`).

**Nested sessions (F12 toggle):** F12 suspends all local key bindings and passes keystrokes through to an inner remote session. Visual style changes indicate the "off" state. Remote sessions display status bar at the bottom to avoid stacking with the local top bar.

## Non-obvious key bindings

| Binding | Action |
|---------|--------|
| `C-a \|` | Horizontal split (retains cwd) |
| `C-a _` | Vertical split (retains cwd) |
| `C-a [` / `]` | Previous/next pane |
| `C-a C-[` / `C-]` | Previous/next window |
| `C-a +` | Zoom pane |
| `C-a Tab` | Last window (MRU) |
| `C-a C-e` | Open tmux.conf in `$EDITOR`, reload on save |
| `C-a Enter` | Reload config |
| `C-a $` | Renew env vars in all idle panes |
| `F12` | Toggle pass-through to nested session |
| `M-Up` | Enter copy mode |

Copy mode uses vi keys; `y`/`Enter` yanks via `yank.sh`.
