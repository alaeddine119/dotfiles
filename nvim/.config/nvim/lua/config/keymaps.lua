-- ========================================================================== --
--  GLOBAL KEYMAPS
-- ========================================================================== --
local map = vim.keymap.set

-- -------------------------------------------------------------------------- --
--  CORE NAVIGATION & BEHAVIOR
-- -------------------------------------------------------------------------- --
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down & center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up & center" })
map("n", "n", "nzzzv", { desc = "Next search result & center" })
map("n", "N", "Nzzzv", { desc = "Prev search result & center" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
map("n", "<leader><leader>", "<CMD>Oil<CR>", { desc = "File Explorer" })

-- -------------------------------------------------------------------------- --
--  SNACKS: PICKERS, SEARCH, BUFFERS, GIT
-- -------------------------------------------------------------------------- --
map("n", "<leader>sf", function()
	Snacks.picker.files()
end, { desc = "Files" })
map("n", "<leader>sr", function()
	Snacks.picker.recent()
end, { desc = "Recent Files" })
map("n", "<leader>sg", function()
	Snacks.picker.grep()
end, { desc = "Grep (Workspace)" })
map("n", "<leader>sw", function()
	Snacks.picker.grep_word()
end, { desc = "Word under cursor" })
map("n", "<leader>sc", function()
	Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Neovim Config" })
map("n", "<leader>sh", function()
	Snacks.picker.help()
end, { desc = "Help Tags" })
map("n", "<leader>sd", function()
	Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
map("n", "<leader>sp", function()
	Snacks.picker.projects()
end, { desc = "Projects" })
map("n", "<leader>sR", function()
	Snacks.picker.registers()
end, { desc = "Registers" })

map({ "n", "t" }, "<C-t>", function()
	Snacks.terminal.toggle()
end, { desc = "Toggle Terminal" })
map("n", "<leader>tz", function()
	Snacks.zen()
end, { desc = "Zen Mode" })

map("n", "z=", function()
	Snacks.picker.spelling({
		win = {
			input = { wo = { rightleft = vim.wo.rightleft } },
			list = { wo = { rightleft = vim.wo.rightleft } },
		},
	})
end, { desc = "Spell Suggestions" })

map("n", "<leader>bb", function()
	Snacks.picker.buffers()
end, { desc = "List Buffers" })
map("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>b.", function()
	Snacks.scratch()
end, { desc = "Scratch Buffer" })
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })

map("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "Lazygit" })
map("n", "<leader>gb", function()
	Snacks.gitbrowse()
end, { desc = "Git Browse" })

-- -------------------------------------------------------------------------- --
--  CODE, FORMATTING & TROUBLE
-- -------------------------------------------------------------------------- --
map("n", "<leader>cf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })
map("n", "<leader>cr", function()
	Snacks.rename.rename_file()
end, { desc = "Rename File" })
map(
	"n",
	"<leader>cs",
	"<cmd>Trouble symbols toggle focus=false<cr>",
	{ desc = "Symbols" }
)
map(
	"n",
	"<leader>cl",
	"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
	{ desc = "LSP References" }
)

map(
	"n",
	"<leader>xx",
	"<cmd>Trouble diagnostics toggle<cr>",
	{ desc = "Workspace" }
)
map(
	"n",
	"<leader>xX",
	"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
	{ desc = "Document" }
)

-- -------------------------------------------------------------------------- --
--  TOGGLES & NOTIFICATIONS
-- -------------------------------------------------------------------------- --
map("n", "<leader>nh", function()
	Snacks.notifier.show_history()
end, { desc = "History" })
map("n", "<leader>nd", function()
	Snacks.notifier.hide()
end, { desc = "Dismiss" })

map("n", "<leader>tw", function()
	require("mini.trailspace").trim()
end, { desc = "Trim Whitespace" })
map("n", "<leader>tu", vim.cmd.UndotreeToggle, { desc = "UndoTree" })
