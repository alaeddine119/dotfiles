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

# --- 3. Start Zellij
# Only auto-start Zellij if:
# 1. We are NOT already in Zellij
# 2. We are NOT on the raw TTY console (TERM usually equals 'linux')
# 3. We are in an interactive session
if [[ -z "$ZELLIJ" && "$TERM" != "linux" && $- == *i* ]]; then
    eval "$(zellij setup --generate-auto-start bash)"
fi

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

# --- 4. Aliases ---
alias ls="eza -lh"
alias ll="eza -alh"
alias tree="eza --tree"
alias cat="bat"

# --- 4. VS Code Integration ---
[[ "$TERM_PROGRAM" == "vscode" ]] && . "/usr/share/code/resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-bash.sh"

# --- 5. FZF Integration (Keybindings) ---
# This allows Alt+C to jump folders and Ctrl+R for history
if [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
	. /usr/share/fzf/shell/key-bindings.bash
fi

# --- 6. Starship ---
eval "$(starship init bash)"

# --- 7. Zoxide (MUST BE LAST) ---

# Initialize zoxide replacing 'cd'
eval "$(zoxide init --cmd cd bash)"




eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
