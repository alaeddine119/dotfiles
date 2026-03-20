-- ========================================================================== --
--  TESTING: Vim-Test + Vimux
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/vim-test/vim-test",
	"https://github.com/preservim/vimux",
})

-- 2. CONFIGURE
vim.g["test#strategy"] = "vimux"
vim.g.VimuxOrientation = "h"
vim.g.VimuxHeight = "35"
