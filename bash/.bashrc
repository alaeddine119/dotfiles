# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
	PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi
unset rc
. "$HOME/.cargo/env"

# --- 3. Aliases ---
alias ls="eza -lh"
alias ll="eza -alh"
alias tree="eza --tree"
alias cat="bat"

# --- 4. Tool Initializations ---
# Initialize zoxide (smarter cd)
eval "$(zoxide init --cmd cd bash)"

export PATH="$PATH:/opt/nvim-linux-arm64/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

export GTK_THEME=Adwaita:dark

export EDITOR='nvim'
export VISUAL='nvim'

# --- 5. VS Code Integration ---
# On Fedora, this path will likely change to: /usr/share/code/...
[[ "$TERM_PROGRAM" == "vscode" ]] && . "/usr/share/code/resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-bash.sh"
