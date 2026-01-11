# .bashrc
# --- 1. Global Definitions ---
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
	PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH
export PATH="$PATH:/opt/nvim-linux-arm64/bin"

# --- 2. Tool Settings & Exports ---
export EDITOR='nvim'
export VISUAL='nvim'


# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# User specific aliases
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then . "$rc"; fi
	done
fi
unset rc
. "$HOME/.cargo/env"

# --- 3. Interactive Shell Settings (History & Keys) ---

# [NEW] Map Up/Down arrows to partial history search
# Type 'git c' and press Up to see 'git commit', 'git checkout', etc.
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'


# --- 4. Aliases ---
alias ls="eza -lh"
alias ll="eza -alh"
alias tree="eza --tree"
alias cat="bat"

# --- 5. VS Code Integration ---
[[ "$TERM_PROGRAM" == "vscode" ]] && . "/usr/share/code/resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-bash.sh"

# --- 6. FZF Integration (Keybindings) ---
# Loads keybindings (Ctrl+R, Alt+C) and auto-completion
[ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
[ -f /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash


# --- 7. Starship ---
eval "$(starship init bash)"

# --- 8. Zoxide (MUST BE LAST) ---

# Initialize zoxide replacing 'cd'
eval "$(zoxide init --cmd cd bash)"


eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"


