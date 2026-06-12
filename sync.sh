#!/usr/bin/env bash
# Back up dotfiles: copy live configs from $HOME into this repo, then commit + push.
# Usage: ./sync.sh ["commit message"]
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
cd "$REPO_ROOT"

msg="${1:-Update dotfiles}"
staged=()

for entry in "${MAPPINGS[@]}"; do
  parse_mapping "$entry"
  if [ ! -e "$M_SRC" ]; then
    echo "skip: $M_SRC not found"
    continue
  fi
  if [ "$M_TYPE" = "dir" ]; then
    rm -rf "$M_DEST"
    cp -R "$M_SRC" "$M_DEST"
  else
    mkdir -p "$(dirname "$M_DEST")"
    cp "$M_SRC" "$M_DEST"
  fi
  rel="${M_DEST#"$REPO_ROOT"/}"
  staged+=("$rel")
  echo "synced: $M_SRC -> $rel"
done

git add "${staged[@]}"

if git diff --cached --quiet; then
  echo "No changes to commit."
  exit 0
fi

git commit -m "$msg"
git push origin main
