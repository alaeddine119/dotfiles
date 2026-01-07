-- ========================================================================== --
--  PLUGIN: VIM-TMUX-NAVIGATOR
--  Seamless navigation between Neovim splits and Tmux panes using C-h/j/k/l
-- ========================================================================== --

-- 1. Install
vim.pack.add({
	"https://github.com/christoomey/vim-tmux-navigator",
})

-- 2. Configuration
--    By default, this plugin maps <C-h>, <C-j>, <C-k>, <C-l>.
--    If you want to disable default mappings and set your own:
--    vim.g.tmux_navigator_no_mappings = 1

--    Write all buffers before navigating from Vim to Tmux pane
vim.g.tmux_navigator_save_on_switch = 2

-- 3. Keymaps (Optional - defaults are usually fine)
--    If you disabled defaults above, map them here:
--    vim.keymap.set('n', '<C-h>', ':TmuxNavigateLeft<CR>')
--    vim.keymap.set('n', '<C-j>', ':TmuxNavigateDown<CR>')
--    vim.keymap.set('n', '<C-k>', ':TmuxNavigateUp<CR>')
--    vim.keymap.set('n', '<C-l>', ':TmuxNavigateRight<CR>')
