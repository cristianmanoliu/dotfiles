# dotfiles

Backup + restore of my macOS config files.

## What's backed up

| Config | Source | Repo dir |
|--------|--------|----------|
| Neovim | `~/.config/nvim` | `nvim/` |
| tmux | `~/.tmux` | `tmux/` |
| WezTerm | `~/.wezterm.lua` | `wezterm/` |
| zk | `~/.config/zk` | `zk/` |
| zsh | `~/.zshrc`, `~/.zshenv`, `~/.zprofile` | `zsh/` |
| bash | `~/.bashrc` | `bash/` |
| git | `~/.gitconfig` | `git/` |

## Usage

### Back up (this machine → repo)

```bash
./sync.sh                  # copy live configs into repo, commit, push
./sync.sh "custom message" # with a commit message
```

### Restore (repo → a machine)

```bash
git clone <this-repo> && cd dotfiles
./install.sh               # restore configs into $HOME
./install.sh --dry-run     # preview without changing anything
```

`install.sh` backs up any existing target to `<target>.bak-<timestamp>` before
overwriting, and initializes git submodules.

## Notes

- **Secrets stay out.** `~/.zshrc` sources `~/.secrets.zsh` (API keys etc.),
  which is gitignored and never committed. Keep secrets there.
- **Submodule:** `tmux/plugins/smart-splits.nvim`. Fresh clones run
  `git submodule update --init --recursive` (handled by `install.sh`).
- **tmux-resurrect** writes runtime session state; that path is gitignored.
- The mapping table lives once in `lib.sh`, shared by both scripts.
