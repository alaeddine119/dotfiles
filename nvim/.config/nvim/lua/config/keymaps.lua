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
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- -------------------------------------------------------------------------- --
--  SNACKS: PICKERS & SEARCH (<leader>s)
-- -------------------------------------------------------------------------- --
map("n", "<leader>sf", function()
	Snacks.picker.files()
end, { desc = "[S]earch [F]iles" })
map("n", "<leader>sr", function()
	Snacks.picker.recent()
end, { desc = "[S]earch [R]ecent Files" })
map("n", "<leader>sb", function()
	Snacks.picker.buffers()
end, { desc = "[S]earch [B]uffers" })
map("n", "<leader>sg", function()
	Snacks.picker.grep()
end, { desc = "[S]earch [G]rep (Workspace)" })
map("n", "<leader>sw", function()
	Snacks.picker.grep_word()
end, { desc = "[S]earch [W]ord under cursor" })
map("n", "<leader>sc", function()
	Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [C]onfig" })
map("n", "<leader>sh", function()
	Snacks.picker.help()
end, { desc = "[S]earch [H]elp Tags" })
map("n", "<leader>sH", function()
	Snacks.picker.command_history()
end, { desc = "[S]earch [H]istory (Cmd)" })
map("n", "<leader>sd", function()
	Snacks.picker.diagnostics()
end, { desc = "[S]earch [D]iagnostics" })
map("n", "<leader>sp", function()
	Snacks.picker.projects()
end, { desc = "[S]earch [P]rojects" })

-- -------------------------------------------------------------------------- --
--  SNACKS: BUFFERS, GIT & TERMINAL (<leader>b, <leader>g)
-- -------------------------------------------------------------------------- --
map("n", "<leader>bh", function()
	Snacks.dashboard()
end, { desc = "Open [H]ome Dashboard" })
map("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "[B]uffer [D]elete" })
map("n", "<leader>b.", function()
	Snacks.scratch()
end, { desc = "[B]uffer Scratch" })
map("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "[G]it Lazy[g]it" })
map("n", "<leader>gb", function()
	Snacks.gitbrowse()
end, { desc = "[G]it [B]rowse" })
map({ "n", "t" }, "<c-/>", function()
	Snacks.terminal()
end, { desc = "Toggle Terminal" })

-- -------------------------------------------------------------------------- --
--  CODE & COMPILATION (<leader>c)
-- -------------------------------------------------------------------------- --
map("n", "<leader>cf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[C]ode [F]ormat" })
map("n", "<leader>cb", "<cmd>Compile<CR>", { desc = "[C]ode [B]uild" })
map("n", "<leader>cx", "<cmd>Recompile<CR>", { desc = "[C]ode Recompile" })
map("n", "<leader>cr", function()
	Snacks.rename.rename_file()
end, { desc = "[C]ode [R]ename File" })

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
	{ desc = "Project Diagnostics" }
)
map(
	"n",
	"<leader>xX",
	"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
	{ desc = "Buffer Diagnostics" }
)
map(
	"n",
	"<leader>cs",
	"<cmd>Trouble symbols toggle focus=false<cr>",
	{ desc = "Symbols (Trouble)" }
)
map(
	"n",
	"<leader>cl",
	"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
	{ desc = "LSP References (Trouble)" }
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
end, { desc = "[D]ebug [S]tart/Continue" })
map("n", "<leader>di", function()
	require("dap").step_into()
end, { desc = "[D]ebug Step [I]nto" })
map("n", "<leader>do", function()
	require("dap").step_over()
end, { desc = "[D]ebug Step [O]ver" })
map("n", "<leader>dO", function()
	require("dap").step_out()
end, { desc = "[D]ebug Step [O]ut" })
map("n", "<leader>db", function()
	require("dap").toggle_breakpoint()
end, { desc = "[D]ebug [B]reakpoint" })
map("n", "<leader>dB", function()
	require("dap").set_breakpoint(vim.fn.input("Condition: "))
end, { desc = "[D]ebug [B]reakpoint (Cond)" })
map("n", "<leader>du", function()
	require("dapui").toggle()
end, { desc = "[D]ebug [U]I Toggle" })
map("n", "<leader>de", function()
	require("dapui").eval()
end, { desc = "[D]ebug [E]val" })

-- -------------------------------------------------------------------------- --
--  TESTING (<leader>r)
-- -------------------------------------------------------------------------- --
map("n", "<leader>rn", ":TestNearest<CR>", { desc = "[R]un [N]earest Test" })
map("n", "<leader>rf", ":TestFile<CR>", { desc = "[R]un [F]ile Tests" })
map("n", "<leader>rs", ":TestSuite<CR>", { desc = "[R]un [S]uite" })
map("n", "<leader>rl", ":TestLast<CR>", { desc = "[R]un [L]ast Test" })
map("n", "<leader>rv", ":TestVisit<CR>", { desc = "[R]un [V]isit Test" })
map(
	"n",
	"<leader>ri",
	":VimuxZoomRunner<CR>",
	{ desc = "[R]un [I]nspect Output" }
)

-- -------------------------------------------------------------------------- --
--  TOGGLES (<leader>t)
-- -------------------------------------------------------------------------- --
map(
	"n",
	"<leader>tv",
	"<cmd>NvimContextVtToggle<CR>",
	{ desc = "[T]oggle [V]irtual Context" }
)
map("n", "<leader>td", function()
	require("tiny-inline-diagnostic").toggle()
end, { desc = "[T]oggle Inline [D]iagnostics" })
map("n", "<leader>tw", function()
	require("mini.trailspace").trim()
end, { desc = "[T]rim [W]hitespace" })
map("n", "<leader>U", vim.cmd.UndotreeToggle, { desc = "[U]ndoTree Toggle" })
