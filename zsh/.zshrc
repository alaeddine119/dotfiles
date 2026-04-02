# =================================================== #
# ZINIT INSTALLATION & BOOTSTRAP #
# ================================================== #
# This block automatically installs Zinit if it isn't already installed.
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# =================================================== #
# PLUGINS #
# =================================================== #
# Load completions, syntax highlighting, and autosuggestions asynchronously
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

# Completion plugins from Oh My Zsh
zinit snippet OMZP::docker
zinit snippet OMZP::docker-compose
zinit snippet OMZP::pip
zinit snippet OMZP::node
zinit snippet OMZP::npm
zinit snippet OMZP::vscode
zinit snippet OMZP::command-not-found

# Initialize Zsh's advanced completion system
autoload -Uz compinit && compinit

# replaces Zsh's default completion menu with an interactivy
zinit light Aloxaf/fzf-tab

# =================================================== #
# ZSH OPTIONS & HISTORY #
# =================================================== #
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history       # Record timestamp of command in HISTFILE
setopt hist_expire_dups_first # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # Ignore duplicated commands history list
setopt hist_ignore_space      # Ignore commands that start with space
setopt share_history          # Share history between all active sessions

# Zsh native history search (Up/Down arrows search based on what you already typed)
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# Preview directory contents with eza when auto-completing cd/z
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath'

# =================================================== #
# PATH & EDITOR SETUP #
# =================================================== #
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

export EDITOR='nvim'
export VISUAL='nvim'

# ================================================== #
#  TOOL INITIALIZATION (Zoxide, Starship, Mise) #
# ================================================== #
eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"
eval "$(/home/alaeddine/.local/bin/mise activate zsh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# ================================================== #
#  ENVIRONMENT VARIABLES (NVM, Cargo, Bun, Doom)  #
# ================================================== #
# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Rust/Cargo
. "$HOME/.cargo/env"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Doom Emacs
if [ -d "$HOME/.config/emacs/bin" ]; then
    export PATH="$HOME/.config/emacs/bin:$PATH"
fi

# pnpm
export PNPM_HOME="/home/alaeddine/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Bob Neovim Manager
if [ -f "$HOME/.local/share/bob/env/env.sh" ]; then
    . "$HOME/.local/share/bob/env/env.sh"
fi

# UV
eval "$(uv generate-shell-completion zsh)"

# Completions
# Rust/Cargo Completions (via Rustup)
if command -v rustup &> /dev/null; then
    source <(rustup completions zsh)
fi

# Bun Completions
if command -v bun &> /dev/null; then
    source <(bun completions)
fi

# PNPM Completions
if command -v pnpm &> /dev/null; then
    source <(pnpm completion zsh)
fi

# ================================================== #
# ALIASES & FZF  #
# ================================================== #
alias ls="eza -lh"
alias ll="eza -alh"
alias tree="eza --tree"
alias cat="bat"

export FZF_COMPLETION_OPTS="--preview 'eval v={1} 2>/dev/null; if [ -d \"\$v\" ]; then eza --tree --color=always -- \"\$v\" | head -200; else bat -n --color=always --line-range :500 -- \"\$v\"; fi'"

# Load FZF key bindings for Zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# ================================================== #
#  CUSTOM SCRIPTS  #
# ================================================== #
# Load custom user scripts from ~/.zshrc.d if they exist
if [ -d ~/.zshrc.d ]; then
  for rc in ~/.zshrc.d/*; do
    if [ -f "$rc" ]; then . "$rc"; fi
  done
fi
unset rc
