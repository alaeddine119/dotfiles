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

-- 3. KEYMAPS (Using <leader>r prefix to avoid toggle collisions)
local map = function(keys, func, desc)
	vim.keymap.set("n", keys, func, { desc = "Test: " .. desc })
end

map("<leader>rn", ":TestNearest<CR>", "Nearest")
map("<leader>rf", ":TestFile<CR>", "File")
map("<leader>rs", ":TestSuite<CR>", "Suite")
map("<leader>rl", ":TestLast<CR>", "Last")
map("<leader>rv", ":TestVisit<CR>", "Visit")
map("<leader>ri", ":VimuxZoomRunner<CR>", "Inspect Output")
