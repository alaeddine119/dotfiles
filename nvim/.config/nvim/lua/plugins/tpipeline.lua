-- ========================================================================== --
--  PLUGIN: VIM-TPIPELINE
--  Embeds the Neovim statusline into the Tmux status bar.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({ "https://github.com/vimpostor/vim-tpipeline" })

-- 2. CONFIGURE
-- Ensure True Color for Tmux integration
vim.opt.termguicolors = true

-- 1 = Force restore statusline on events (prevents flickering)
vim.g.tpipeline_restore = 1
