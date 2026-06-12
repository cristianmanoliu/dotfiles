#!/usr/bin/env bash
# Shared config for sync.sh + install.sh.
# Single source of truth for the dotfile mapping table.
# shellcheck disable=SC2034  # MAPPINGS/M_* consumed by scripts that source this file

# Repo root = dir this script lives in.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Mapping table: each entry is "TYPE|SOURCE|DEST".
#   TYPE = dir | file
#   SOURCE = path under $HOME (absolute, ~ expanded)
#   DEST   = path under repo root (relative)
# sync.sh copies SOURCE -> DEST. install.sh copies DEST -> SOURCE.
MAPPINGS=(
  "dir|$HOME/.config/nvim|nvim"
  "dir|$HOME/.tmux|tmux"
  "file|$HOME/.wezterm.lua|wezterm/.wezterm.lua"
  "dir|$HOME/.config/zk|zk"
  "file|$HOME/.zshrc|zsh/.zshrc"
  "file|$HOME/.zshenv|zsh/.zshenv"
  "file|$HOME/.zprofile|zsh/.zprofile"
  "file|$HOME/.bashrc|bash/.bashrc"
  "file|$HOME/.gitconfig|git/.gitconfig"
)

# Parse a mapping entry into globals: M_TYPE, M_SRC, M_DEST (absolute).
parse_mapping() {
  local entry="$1"
  M_TYPE="${entry%%|*}"
  local rest="${entry#*|}"
  M_SRC="${rest%%|*}"
  M_DEST="$REPO_ROOT/${rest##*|}"
}
