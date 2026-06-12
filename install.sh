#!/usr/bin/env bash
# Restore dotfiles onto this machine: copy configs from this repo into $HOME.
# Existing targets are backed up to <target>.bak-<timestamp> before overwrite.
# Usage: ./install.sh [--dry-run]
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
cd "$REPO_ROOT"

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

run() {
  if [ "$DRY_RUN" = 1 ]; then
    echo "DRY: $*"
  else
    "$@"
  fi
}

# Pull submodules (e.g. tmux/plugins/smart-splits.nvim) so a fresh clone is complete.
echo "==> Initializing submodules"
run git submodule update --init --recursive

ts="$(date +%Y%m%d-%H%M%S)"

for entry in "${MAPPINGS[@]}"; do
  parse_mapping "$entry"
  if [ ! -e "$M_DEST" ]; then
    echo "skip: repo missing $M_DEST"
    continue
  fi

  # Back up existing target before overwriting (non-destructive).
  if [ -e "$M_SRC" ] || [ -L "$M_SRC" ]; then
    echo "backup: $M_SRC -> $M_SRC.bak-$ts"
    run mv "$M_SRC" "$M_SRC.bak-$ts"
  fi

  run mkdir -p "$(dirname "$M_SRC")"
  if [ "$M_TYPE" = "dir" ]; then
    run cp -R "$M_DEST" "$M_SRC"
  else
    run cp "$M_DEST" "$M_SRC"
  fi
  echo "restored: ${M_DEST#"$REPO_ROOT"/} -> $M_SRC"
done

echo "==> Done. Backups (if any) tagged .bak-$ts"
