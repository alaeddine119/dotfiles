-- ========================================================================== --
--  PLUGIN: DEBUG ADAPTER PROTOCOL (DAP)
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/nvim-neotest/nvim-nio",
	"https://github.com/jay-babu/mason-nvim-dap.nvim",
})

-- 2. GUARD (With Logging)
local status_dap, dap = pcall(require, "dap")
local status_ui, dapui = pcall(require, "dapui")
local status_mason_dap, mason_dap = pcall(require, "mason-nvim-dap")

if not status_dap then
	print("Debug Error: nvim-dap not found. Restart Neovim.")
	return
end

if not status_ui then
	print("Debug Error: nvim-dap-ui not found.")
	return
end

if not status_mason_dap then
	print("Debug Error: mason_dap not found.")
	return
end

-- 3. CONFIGURE UI
dapui.setup({
	icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
	controls = {
		enabled = true,
		element = "repl",
		icons = {
			pause = "⏸",
			play = "▶",
			step_into = "⏎",
			step_over = "⏭",
			step_out = "⏮",
			step_back = "b",
			run_last = "▶▶",
			terminate = "⏹",
			disconnect = "⏏",
		},
	},
	-- Required fields to satisfy Lua LS
	expand_lines = true,
	force_buffers = true,
	element_mappings = {}, -- <--- Added this to fix the warning
	layouts = {
		{
			elements = {
				{ id = "scopes", size = 0.25 },
				{ id = "breakpoints", size = 0.25 },
				{ id = "stacks", size = 0.25 },
				{ id = "watches", size = 0.25 },
			},
			position = "left",
			size = 40,
		},
		{
			elements = {
				{ id = "repl", size = 0.5 },
				{ id = "console", size = 0.5 },
			},
			position = "bottom",
			size = 10,
		},
	},
	floating = {
		max_height = nil,
		max_width = nil,
		border = "single",
		mappings = { close = { "q", "<Esc>" } },
	},
	mappings = {
		edit = "e",
		expand = { "<CR>", "<2-LeftMouse>" },
		open = "o",
		remove = "d",
		repl = "r",
		toggle = "t",
	},
	render = { indent = 1, max_value_lines = 100 },
})

-- Auto-open UI
dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

-- 4. CONFIGURE MASON-DAP
mason_dap.setup({
	ensure_installed = {
		"codelldb",
	},
	automatic_installation = true,
	handlers = {
		function(config)
			mason_dap.default_setup(config)
		end,
	},
})

-- 5. KEYMAPS
vim.keymap.set(
	"n",
	"<leader>ds",
	dap.continue,
	{ desc = "[D]ebug [S]tart/Continue" }
)
vim.keymap.set(
	"n",
	"<leader>di",
	dap.step_into,
	{ desc = "[D]ebug Step [I]nto" }
)
vim.keymap.set(
	"n",
	"<leader>do",
	dap.step_over,
	{ desc = "[D]ebug Step [O]ver" }
)
vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "[D]ebug Step [O]ut" })
vim.keymap.set(
	"n",
	"<leader>db",
	dap.toggle_breakpoint,
	{ desc = "[D]ebug [B]reakpoint" }
)
vim.keymap.set("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "[D]ebug [B]reakpoint (Cond)" })
vim.keymap.set(
	"n",
	"<leader>du",
	dapui.toggle,
	{ desc = "[D]ebug [U]I Toggle" }
)
vim.keymap.set("n", "<leader>de", dapui.eval, { desc = "[D]ebug [E]val" })

-- 6. MANUAL CONFIGURATIONS
-- Mason installs the adapter ('codelldb'), but we need to tell Neovim how to use it for C++.
dap.configurations.cpp = {
	{
		name = "Launch file",
		type = "codelldb",
		request = "launch",
		program = function()
			-- Asks you to select the executable to debug
			return vim.fn.input(
				"Path to executable: ",
				vim.fn.getcwd() .. "/",
				"file"
			)
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
}

-- Apply the same config to C and Objective-C
dap.configurations.c = dap.configurations.cpp
dap.configurations.objc = dap.configurations.cpp
