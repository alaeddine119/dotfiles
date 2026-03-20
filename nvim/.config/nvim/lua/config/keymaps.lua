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
local map = vim.keymap.set

-- Files & Buffers
map("n", "<leader>ff", function()
	Snacks.picker.files()
end, { desc = "Find [F]iles" })
map("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, { desc = "Find [B]uffers" })
map("n", "<leader>fr", function()
	Snacks.picker.recent()
end, { desc = "Find [R]ecent Files" })

-- Grep & Text
map("n", "<leader>sg", function()
	Snacks.picker.grep()
end, { desc = "[S]earch [G]rep (Workspace)" })
map("n", "<leader>sw", function()
	Snacks.picker.grep_word()
end, { desc = "[S]earch [W]ord under cursor" })

-- Neovim & LSP
map("n", "<leader>sh", function()
	Snacks.picker.help()
end, { desc = "[S]earch [H]elp Tags" })
map("n", "<leader>sc", function()
	Snacks.picker.command_history()
end, { desc = "[S]earch [C]ommand History" })
map("n", "<leader>sd", function()
	Snacks.picker.diagnostics()
end, { desc = "[S]earch [D]iagnostics" })

-- ========================================================================== --
--  SEARCH & PICKER (Powered by Snacks)
-- ========================================================================== --
local map = vim.keymap.set

-- Core File Search
map("n", "<leader>sf", function()
	Snacks.picker.files()
end, { desc = "[S]earch [F]iles" })
map("n", "<leader>sr", function()
	Snacks.picker.recent()
end, { desc = "[S]earch [R]ecent Files" })
map("n", "<leader>sb", function()
	Snacks.picker.buffers()
end, { desc = "[S]earch [B]uffers" })

-- Text / Grep Search
map("n", "<leader>sg", function()
	Snacks.picker.grep()
end, { desc = "[S]earch [G]rep (Workspace)" })
map("n", "<leader>sw", function()
	Snacks.picker.grep_word()
end, { desc = "[S]earch [W]ord under cursor" })

-- Neovim Config & Internal
map("n", "<leader>sc", function()
	-- This tells Snacks to specifically search inside your ~/.config/nvim folder!
	Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [C]onfig" })

map("n", "<leader>sh", function()
	Snacks.picker.help()
end, { desc = "[S]earch [H]elp Tags" })
