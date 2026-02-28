# .bashrc

# =========================================================================== #
#  SECTION 0: BLE.SH INITIALIZATION (MUST BE FIRST)                           #
# =========================================================================== #
# We source ble.sh immediately, but use '--attach=none'.
# This prepares the environment but waits until the end of .bashrc to
# actually take over the keyboard. This prevents conflicts during load.
[[ $- == *i* ]] && [ -f /usr/share/blesh/ble.sh ] && source /usr/share/blesh/ble.sh --attach=none

# =========================================================================== #
#  SECTION 1: GLOBAL DEFINITIONS                                              #
# =========================================================================== #
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# =========================================================================== #
#  SECTION 2: PATH & EDITOR SETUP                                             #
# =========================================================================== #
# Standard path hygiene
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH="$PATH:/opt/nvim-linux-arm64/bin"

# Set preferred editors
export EDITOR='nvim'
export VISUAL='nvim'

# =========================================================================== #
#  SECTION 3: SYSTEM COMPLETION (CRITICAL DEPENDENCY)                         #
# =========================================================================== #
# ble.sh and fzf-integration rely on the system's bash_completion being
# loaded BEFORE they initialize.
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# =========================================================================== #
#  SECTION 4: ZOXIDE (MUST LOAD BEFORE FZF SETTINGS)                          #
# =========================================================================== #
# Initialize zoxide to replace 'cd'. We do this early so completion engines
# pick up the new 'cd' behavior.
eval "$(zoxide init --cmd cd bash)"

# =========================================================================== #
#  SECTION 5: TOOL SETTINGS (NVM, CARGO)                                      #
# =========================================================================== #
# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Rust/Cargo
. "$HOME/.cargo/env"

# --- BUN SETUP ---
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# --- DOOM SETUP ---
if [ -d "$HOME/.config/emacs/bin" ]; then # Changed -f to -d
    export PATH="$HOME/.config/emacs/bin:$PATH"
fi

if [ -d "$HOME/.config/emacs/bin" ]; then # Changed -f to -d
    export PATH="$HOME/.config/emacs/bin:$PATH"
fi

# --- UV
eval "$(uv generate-shell-completion bash)"

# Load custom user scripts from ~/.bashrc.d if they exist
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then . "$rc"; fi
    done
fi
unset rc

# =========================================================================== #
#  SECTION 6: ALIASES & INTERACTIVE SETTINGS                                  #
# =========================================================================== #
# Aliases
alias ls="eza -lh"
alias ll="eza -alh"
alias tree="eza --tree"
alias cat="bat"

# NOTE: We removed the manual 'bind' commands for history search here.
# ble.sh handles Up/Down arrow history searching natively and provides
# a better, syntax-highlighted experience out of the box.

# =========================================================================== #
#  SECTION 7: FZF CONFIGURATION                                               #
# =========================================================================== #
# We define the preview options here so both standard FZF and ble.sh
# integration can read them.
# 1. 'eval v={}' unquotes filenames.
# 2. Uses 'eza' for directories and 'bat' for files.
# 3. 2>/dev/null silences errors on empty selections.
export FZF_COMPLETION_OPTS="--preview 'eval v={1} 2>/dev/null; if [ -d \"\$v\" ]; then eza --tree --color=always -- \"\$v\" | head -200; else bat -n --color=always --line-range :500 -- \"\$v\"; fi'"

# --- FALLBACK MECHANISM ---
# If ble.sh is NOT running (e.g., inside a script or older bash),
# we load the standard FZF bindings as a backup.
if [[ ! ${BLE_VERSION-} ]]; then
    [ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
    [ -f /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash
fi
# NOTE: If ble.sh IS running, the settings in ~/.blerc take over.

# =========================================================================== #
#  SECTION 8: VS CODE INTEGRATION                                             #
# =========================================================================== #
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    if [ -f "/opt/visual-studio-code/resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-bash.sh" ]; then
        . "/opt/visual-studio-code/resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-bash.sh"
    fi
fi

# =========================================================================== #
#  SECTION 9: PROMPT & FINALIZATION                                           #
# =========================================================================== #
# Initialize Starship
eval "$(starship init bash)"

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# =========================================================================== #
#  SECTION 10: BLE.SH ATTACH (MUST BE LAST)                                   #
# =========================================================================== #
# Now that paths, completions, starship, and env vars are set,
# we tell ble.sh to take control of the terminal line editor.
bind 'set enable-bracketed-paste on'
[[ ! ${BLE_VERSION-} ]] || ble-attach

# pnpm
export PNPM_HOME="/home/alaeddine/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
