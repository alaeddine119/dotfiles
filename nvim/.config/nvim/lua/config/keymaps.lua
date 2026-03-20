-- ========================================================================== --
--  GLOBAL KEYMAPS
-- ========================================================================== --

local map = vim.keymap.set

-- Navigation & Search
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("t", "<Esc><Esc>", [[<C-\><C-n>]])
map("n", "<leader>bh", function()
	Snacks.dashboard()
end, { desc = "Open [Home] Dashboard" })

-- Diagnostics (Native 0.10+ style)
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev Diagnostic" })
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next Diagnostic" })

-- Compilation
map("n", "<leader>cb", "<cmd>Compile<CR>", { desc = "Build" })
map("n", "<leader>cx", "<cmd>Recompile<CR>", { desc = "Rerun" })
map("n", "]e", "<cmd>NextError<CR>")
map("n", "[e", "<cmd>PrevError<CR>")
