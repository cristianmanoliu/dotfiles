#!/usr/bin/env bash
# resurrect-autoclaude.sh
# Called by @resurrect-hook-post-restore-all (via `tmux run-shell -b`).
#
# After a full tmux-resurrect restore, for each restored pane that is:
#   - the active pane in its window
#   - running a bare interactive shell (zsh/bash)
#   - whose cwd has a matching ~/Main/notes/ai/handoffs/<project>_claude.md
# ...send-keys `claude` Enter. The existing SessionStart pickoff hook
# (~/.claude/hooks/handoff-pickoff-check.sh) then auto-resumes the handoff.
#
# Opt-in gate: @auto-claude-handoff must be 'on' (set in tmux.conf).
# Toggle off at runtime: tmux set -g @auto-claude-handoff off
# Idempotent per save-file: marker keyed on the `last` symlink target.

set -eu

HANDOFFS_DIR="${HOME}/Main/notes/ai/handoffs"
RESURRECT_DIR="${HOME}/.local/share/tmux/resurrect"
MARKER="${RESURRECT_DIR}/.autoclaude-done"
SETTLE_SECONDS=2  # wait for restored shells to become interactive
CLAUDE_READY_SECONDS=6  # wait for claude TUI to accept input before sending /pickoff

# ---------------------------------------------------------------------------
# Gate: opt-in option
# ---------------------------------------------------------------------------
enabled="$(tmux show-option -gqv @auto-claude-handoff 2>/dev/null || true)"
[ "${enabled}" = "on" ] || exit 0

# ---------------------------------------------------------------------------
# Idempotency: skip if this exact save file was already handled
# ---------------------------------------------------------------------------
current_save="$(readlink "${RESURRECT_DIR}/last" 2>/dev/null || echo "unknown")"
if [ -f "${MARKER}" ] && [ "$(cat "${MARKER}" 2>/dev/null || true)" = "${current_save}" ]; then
  exit 0
fi

# ---------------------------------------------------------------------------
# Let restored shells become interactive before we send keys
# (we run backgrounded via `tmux run-shell -b`, so this sleep is safe)
# ---------------------------------------------------------------------------
sleep "${SETTLE_SECONDS}"

# ---------------------------------------------------------------------------
# Normalization helpers
# Must match the naming convention used by the `handoff` skill.
# ---------------------------------------------------------------------------

# normalize: lowercase; keep [a-z0-9 ._/-]; spaces → -
normalize() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-z0-9 ._\/-]//g' \
    | tr ' ' '-'
}

# strip_lead: remove leading dots and dashes (.claude → claude, .config → config)
strip_lead() {
  printf '%s' "$1" | sed 's/^[.-]*//'
}

# resolve_handoff <cwd>
# Tries two candidates (c1=basename, c2=parent-basename) against the handoffs dir.
# Echoes the matched project name on success; returns non-zero on no match.
resolve_handoff() {
  local cwd="$1"
  local base parent nb np c1 c2 cand
  base="$(basename "${cwd}")"
  parent="$(basename "$(dirname "${cwd}")")"
  nb="$(strip_lead "$(normalize "${base}")")"
  np="$(strip_lead "$(normalize "${parent}")")"
  c1="${nb}"
  c2="${np}-${nb}"
  for cand in "${c1}" "${c2}"; do
    [ -n "${cand}" ] || continue
    if [ -f "${HANDOFFS_DIR}/${cand}_claude.md" ]; then
      printf '%s' "${cand}"
      return 0
    fi
  done
  return 1
}

# ---------------------------------------------------------------------------
# Enumerate live panes and dispatch
# NOTE: running claude reports its *version string* (e.g. 2.1.159) as
# pane_current_command — NOT "claude". So we WHITELIST shells (zsh/bash);
# never try to blacklist claude by command name.
# ---------------------------------------------------------------------------
seen_sessions=" "  # space-delimited set; " sess " membership check
dispatched=0

while IFS='|' read -r target_raw cmd path; do
  [ -n "${target_raw:-}" ] || continue

  # Strip :active / :inactive suffix → get the real pane target
  case "${target_raw}" in
    *:active)   active=1; tgt="${target_raw%:active}" ;;
    *:inactive) active=0; tgt="${target_raw%:inactive}" ;;
    *)          active=0; tgt="${target_raw}" ;;
  esac

  # Guard: active pane only
  [ "${active}" = "1" ] || continue

  # Guard: bare interactive shell only
  case "${cmd}" in
    zsh|bash|-zsh|-bash) : ;;
    *) continue ;;
  esac

  # Guard: one claude per tmux session
  sess="${tgt%%:*}"
  case "${seen_sessions}" in
    *" ${sess} "*) continue ;;
  esac

  # Guard: cwd must have a matching handoff doc
  resolve_handoff "${path}" >/dev/null 2>&1 || continue

  # Dispatch step 1: launch claude (alias expands in interactive zsh).
  tmux send-keys -t "${tgt}" 'claude' Enter

  # Dispatch step 2: the SessionStart hook injects "invoke pickoff" context,
  # but additionalContext is passive — the model waits for a user turn before
  # acting. So we give it one: after the TUI is interactive, send /pickoff.
  ( sleep "${CLAUDE_READY_SECONDS}"
    tmux send-keys -t "${tgt}" '/pickoff' Enter
  ) &

  seen_sessions="${seen_sessions}${sess} "
  dispatched=$((dispatched + 1))
done <<EOF
$(tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}#{?pane_active,:active,:inactive}|#{pane_current_command}|#{pane_current_path}' 2>/dev/null || true)
EOF

# ---------------------------------------------------------------------------
# Record marker so re-restore of the same save won't double-fire
# ---------------------------------------------------------------------------
printf '%s' "${current_save}" > "${MARKER}" 2>/dev/null || true

# Surface what happened (visible in tmux display area)
tmux display-message "auto-claude-handoff: claude launched in ${dispatched} pane(s)" 2>/dev/null || true
exit 0
