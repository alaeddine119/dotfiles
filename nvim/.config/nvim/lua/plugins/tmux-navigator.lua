-- ========================================================================== --
--  PLUGIN: VIM-TMUX-NAVIGATOR
--  Seamless navigation between Neovim splits and Tmux panes using C-h/j/k/l
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({ "https://github.com/christoomey/vim-tmux-navigator" })

-- 2. CONFIGURATION
-- 2 = Save all buffers when switching from Vim to a Tmux pane
vim.g.tmux_navigator_save_on_switch = 2

-- 3. KEYMAPS
-- Defaults (<C-h/j/k/l>) are active automatically.
-- No manual overrides needed unless you want to change the triggers.
