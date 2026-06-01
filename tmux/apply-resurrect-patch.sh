#!/usr/bin/env bash
# Reapply the tmux-resurrect pane-title field-shift fix after a plugin update.
#
# THE BUG: save.sh dump_panes() and restore.sh restore_pane() both parse the
# tab-delimited save lines with `while IFS=$'\t' read ... pane_title dir ...`.
# Tab is an IFS-whitespace char, so an EMPTY pane_title field (two adjacent
# tabs) is collapsed by `read`, shifting every later field left: the dir lands
# in pane_title and pane_active("1") lands in dir. Restore then runs
# `new-window -c "1"`, tmux can't cd to "1", and the pane falls back to $HOME.
#
# THE FIX (mirrors how dir and window_flags already guard themselves): prefix
# pane_title with a ":" sentinel in the save format so the field is never empty,
# and strip that ":" back off on restore. A post-save hook CANNOT fix this --
# the dir is already lost during dump_panes() before the file is written.
#
# This script is idempotent: safe to run any number of times. Run it after
#   ~/.tmux/plugins/tpm/bin/update_plugins all
# if a tmux-resurrect update ever reverts the patch.

set -euo pipefail

RES_DIR="$HOME/.tmux/plugins/tmux-resurrect/scripts"
SAVE="$RES_DIR/save.sh"
RESTORE="$RES_DIR/restore.sh"

fail() { echo "ERROR: $*" >&2; exit 1; }

[ -f "$SAVE" ]    || fail "save.sh not found at $SAVE (is tmux-resurrect installed?)"
[ -f "$RESTORE" ] || fail "restore.sh not found at $RESTORE"

changed=0

# --- Patch 1: save.sh pane_format() -- add ":" sentinel to #{pane_title} ---
if grep -qF 'format+=":#{pane_title}"' "$SAVE"; then
  echo "save.sh:    already patched (:#{pane_title} sentinel present)"
elif grep -qF 'format+="#{pane_title}"' "$SAVE"; then
  # macOS/BSD sed in-place
  sed -i '' 's/format+="#{pane_title}"/format+=":#{pane_title}"/' "$SAVE"
  echo "save.sh:    patched #{pane_title} -> :#{pane_title}"
  changed=1
else
  fail "save.sh: could not find the pane_title format line to patch (upstream changed?)"
fi

# --- Patch 2: restore.sh restore_pane() -- strip ":" sentinel from pane_title ---
# Anchor on the UNIQUE restore_pane() read line (it lists `pane_title dir
# pane_active`, which restore_all_pane_processes' read does NOT). Appending after
# it inserts the strip exactly once, in the right function. The other read loop
# (restore_all_pane_processes) has no pane_title var, so it must NOT be touched.
RP_READ='while IFS=$d read line_type session_name window_number window_active window_flags pane_index pane_title dir pane_active pane_command pane_full_command; do'
if grep -qF 'pane_title="$(remove_first_char "$pane_title")"' "$RESTORE"; then
  echo "restore.sh: already patched (pane_title sentinel strip present)"
elif grep -qF "$RP_READ" "$RESTORE"; then
  # Append the strip on the line after the read (body indent = two tabs).
  sed -i '' "/$(printf '%s' "$RP_READ" | sed 's/[][\\/.*^$]/\\&/g')/a\\
\\	\\	pane_title=\"\$(remove_first_char \"\$pane_title\")\"
" "$RESTORE"
  echo "restore.sh: inserted pane_title sentinel strip"
  changed=1
else
  fail "restore.sh: could not find the restore_pane() read line to anchor on (upstream changed?)"
fi

echo ""
if [ "$changed" -eq 1 ]; then
  echo "Done. Patches applied. Reload not required for the plugin scripts themselves,"
  echo "but run a save to confirm: ~/.tmux/plugins/tmux-resurrect/scripts/save.sh quiet"
else
  echo "Done. Nothing to do -- both patches were already present."
fi
