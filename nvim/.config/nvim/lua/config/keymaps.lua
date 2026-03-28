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
--  SNACKS: PICKERS & SEARCH (<leader>s)
-- -------------------------------------------------------------------------- --
map("n", "<leader>sf", function()
	Snacks.picker.files()
end, { desc = "Files" })
map("n", "<leader>sr", function()
	Snacks.picker.recent()
end, { desc = "Recent Files" })
map("n", "<leader>sb", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })
map("n", "<leader>sk", function()
	Snacks.picker.keymaps()
end, { desc = "Keymaps" })
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
map("n", "<leader>sH", function()
	Snacks.picker.command_history()
end, { desc = "Command History" })
map("n", "<leader>sd", function()
	Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
map("n", "<leader>sp", function()
	Snacks.picker.projects()
end, { desc = "Projects" })

map("n", "<leader>sl", function()
	Snacks.picker.lines()
end, { desc = "Buffer Lines" })
map("n", "<leader>sR", function()
	Snacks.picker.registers()
end, { desc = "Registers" })
map("n", "<leader>sm", function()
	Snacks.picker.marks()
end, { desc = "Marks" })

map({ "n", "t" }, "<C-t>", function()
	Snacks.terminal.toggle()
end, { desc = "Toggle Terminal" })

map("n", "<leader>tz", function()
	Snacks.zen()
end, { desc = "Zen Mode" })

map("n", "z=", function()
	-- Check if the current window is in Right-to-Left mode
	local is_rtl = vim.wo.rightleft

	Snacks.picker.spelling({
		-- Pass the RTL state to the Snacks floating windows
		win = {
			input = { wo = { rightleft = is_rtl } },
			list = { wo = { rightleft = is_rtl } },
		},
	})
end, { desc = "Spell Suggestions" })

-- -------------------------------------------------------------------------- --
--  SNACKS: BUFFERS, GIT (<leader>b, <leader>g)
-- -------------------------------------------------------------------------- --
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
map("n", "<leader>bc", "<cmd>enew<CR>", { desc = "Create Blank Buffer" })
map("n", "<leader>bh", function()
	Snacks.dashboard()
end, { desc = "Dashboard" })

map("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "Lazygit" })

map("n", "<leader>gb", function()
	Snacks.gitbrowse()
end, { desc = "Git Browse" })

-- -------------------------------------------------------------------------- --
--  CODE & COMPILATION (<leader>c)
-- -------------------------------------------------------------------------- --
map("n", "<leader>cf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })
map("n", "<leader>cb", "<cmd>Compile<CR>", { desc = "Build" })
map("n", "<leader>cx", "<cmd>Recompile<CR>", { desc = "Recompile" })
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

-- -------------------------------------------------------------------------- --
--  DIAGNOSTICS & TROUBLE (<leader>x)
-- -------------------------------------------------------------------------- --
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next Diagnostic" })
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev Diagnostic" })
map("n", "]e", "<cmd>NextError<CR>", { desc = "Next Error" })
map("n", "[e", "<cmd>PrevError<CR>", { desc = "Prev Error" })

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
map(
	"n",
	"<leader>xL",
	"<cmd>Trouble loclist toggle<cr>",
	{ desc = "Location List" }
)
map(
	"n",
	"<leader>xQ",
	"<cmd>Trouble qflist toggle<cr>",
	{ desc = "Quickfix List" }
)

-- -------------------------------------------------------------------------- --
--  DEBUGGING (DAP) (<leader>d)
-- -------------------------------------------------------------------------- --
map("n", "<leader>ds", function()
	require("dap").continue()
end, { desc = "Start / Continue" })
map("n", "<leader>di", function()
	require("dap").step_into()
end, { desc = "Step Into" })
map("n", "<leader>do", function()
	require("dap").step_over()
end, { desc = "Step Over" })
map("n", "<leader>dO", function()
	require("dap").step_out()
end, { desc = "Step Out" })
map("n", "<leader>db", function()
	require("dap").toggle_breakpoint()
end, { desc = "Breakpoint" })
map("n", "<leader>dB", function()
	require("dap").set_breakpoint(vim.fn.input("Condition: "))
end, { desc = "Breakpoint (Cond)" })
map("n", "<leader>du", function()
	require("dapui").toggle()
end, { desc = "Toggle UI" })
map("n", "<leader>de", function()
	require("dapui").eval()
end, { desc = "Evaluate" })

-- -------------------------------------------------------------------------- --
--  Notifications (<leader>n)
-- -------------------------------------------------------------------------- --
map("n", "<leader>nh", function()
	Snacks.notifier.show_history()
end, { desc = "History" })
map("n", "<leader>nd", function()
	Snacks.notifier.hide()
end, { desc = "Dismiss" })

-- -------------------------------------------------------------------------- --
--  TESTING (<leader>r)
-- -------------------------------------------------------------------------- --
map("n", "<leader>rn", ":TestNearest<CR>", { desc = "Nearest Test" })
map("n", "<leader>rf", ":TestFile<CR>", { desc = "File Tests" })
map("n", "<leader>rs", ":TestSuite<CR>", { desc = "Test Suite" })
map("n", "<leader>rl", ":TestLast<CR>", { desc = "Last Test" })
map("n", "<leader>rv", ":TestVisit<CR>", { desc = "Visit Test" })
map("n", "<leader>ri", ":VimuxZoomRunner<CR>", { desc = "Inspect Output" })

-- -------------------------------------------------------------------------- --
--  TOGGLES (<leader>t)
-- -------------------------------------------------------------------------- --
map(
	"n",
	"<leader>tv",
	"<cmd>NvimContextVtToggle<CR>",
	{ desc = "Virtual Context" }
)
map("n", "<leader>td", function()
	require("tiny-inline-diagnostic").toggle()
end, { desc = "Inline Diagnostics" })
map("n", "<leader>tw", function()
	require("mini.trailspace").trim()
end, { desc = "Trim Whitespace" })
map("n", "<leader>tu", vim.cmd.UndotreeToggle, { desc = "UndoTree" })

-- -------------------------------------------------------------------------- --
--  WINDOW RESIZING (Arrow Keys)
-- -------------------------------------------------------------------------- --
map("n", "<Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map(
	"n",
	"<Left>",
	"<cmd>vertical resize -2<cr>",
	{ desc = "Decrease Window Width" }
)
map(
	"n",
	"<Right>",
	"<cmd>vertical resize +2<cr>",
	{ desc = "Increase Window Width" }
)
