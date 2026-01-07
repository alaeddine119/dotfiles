-- ========================================================================== --
--  PLUGIN: VIM-TPIPELINE
--  Embeds the Neovim statusline into the Tmux status bar.
-- ========================================================================== --

-- 1. Install
vim.pack.add({
    'https://github.com/vimpostor/vim-tpipeline',
})

-- 2. Configure
--    Disable auto-embed if you want manual control in tmux.conf
--    vim.g.tpipeline_autoembed = 0 

--    Ensure True Color is enabled (Required)
vim.opt.termguicolors = true

--    Force statusline update events
vim.g.tpipeline_restore = 1
