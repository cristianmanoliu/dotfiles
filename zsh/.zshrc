# --- Powerlevel10k instant prompt (keep at top) ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- PATH (single consolidated block; typeset -U de-dupes) ---
typeset -U path fpath
export LUAJIT_PREFIX="$(brew --prefix luajit-openresty)"
export PATH="$HOME/.local/bin:/opt/homebrew/opt/trash/bin:/opt/homebrew/bin:$LUAJIT_PREFIX/bin:$HOME/Library/Python/3.9/bin:$HOME/.lmstudio/bin:$HOME/Main/tools/path:/Applications/WezTerm.app/Contents/MacOS:$PATH"
export PATH="$PATH:$(go env GOPATH)/bin"

# --- Default editor ---
export EDITOR="nvim"
export VISUAL="nvim"

# --- History (one block) ---
HISTFILE="$HOME/.zhistory"
HISTSIZE=50000
SAVEHIST=50000
setopt share_history hist_expire_dups_first hist_ignore_dups hist_verify
setopt inc_append_history extended_history hist_ignore_space hist_reduce_blanks
setopt hist_find_no_dups hist_save_no_dups

# --- Shell options (navigation + globbing + quality-of-life) ---
setopt auto_cd auto_pushd pushd_ignore_dups pushd_silent
setopt extended_glob no_beep interactive_comments

# --- Completion (compinit runs ONCE) ---
fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit
compinit -d "$HOME/.zcompdump"

# completion UX: case-insensitive matching (menu UI handled by fzf-tab below)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'l:|=* r:|=*'
zstyle ':completion:*' group-name ''

# fzf-tab: fuzzy + previewable Tab completion. Load AFTER compinit, BEFORE
# widget-wrapping plugins (autosuggestions/syntax-highlighting). 'menu select' must be unset.
source "/opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh"
zstyle ':fzf-tab:*' fzf-flags --height=80%
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --icons=always --color=always --level=2 $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --tree --icons=always --color=always --level=2 $realpath'

# --- Theme ---
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# --- Autosuggestions (config before sourcing; bind in vi-mode block below) ---
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# --- Zoxide (better cd; keep normal cd, use `z`) ---
eval "$(zoxide init zsh)"

# --- Aliases ---
alias ls="eza --icons=always"
alias ll="eza -l --icons=always"
alias tmux_main="tmux a -t MAIN"

# --- fzf (fd backend + previews via bat/eza) ---
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--height=80% --preview 'bat --color=always --style=numbers --line-range=:200 {}'"
export FZF_CTRL_R_OPTS="--height=60% --preview 'echo {}' --preview-window=down:3:wrap"   # show full cmd
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--height=80% --preview 'eza --tree --icons=always --color=always --level=2 {}'"
source <(fzf --zsh)

# --- Notes directory ---
export ZK_NOTEBOOK_DIR="$HOME/Main/notes"

# --- Vi mode + keybinds (set keymap FIRST, then bind) ---
KEYTIMEOUT=1                                 # ESC reacts instantly (vi mode)
bindkey -v
bindkey '^ ' autosuggest-accept            # Ctrl+Space accepts full suggestion
bindkey '^R' fzf-history-widget            # Ctrl+R = fzf FUZZY history (full-screen list)
bindkey -M vicmd '^R' fzf-history-widget
bindkey '^S' history-incremental-search-forward

# --- Claude Code ---
# export CLAUDE_CODE_EFFORT="medium"
alias claude="claude --dangerously-skip-permissions"

# --- Shell safety guards ---
alias rm='trash'                                   # moves to ~/.Trash instead of permanent delete
alias rf='echo "Blocked: did you mean rm -rf? Use trash -rf if intentional."'

# --- Secrets (API keys etc.; chmod 600, never committed) ---
[ -f "$HOME/.secrets.zsh" ] && source "$HOME/.secrets.zsh"

# --- Syntax highlighting (before history-substring-search per its README) ---
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- History substring search (load LAST, after syntax-highlighting) ---
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up                # Up arrow
bindkey '^[[B' history-substring-search-down              # Down arrow
bindkey "${terminfo[kcuu1]}" history-substring-search-up  # Up (application cursor mode)
bindkey "${terminfo[kcud1]}" history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
