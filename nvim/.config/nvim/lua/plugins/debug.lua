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

-- 2. GUARD
local ok_dap, dap = pcall(require, "dap")
local ok_ui, dapui = pcall(require, "dapui")
local ok_mdap, mason_dap = pcall(require, "mason-nvim-dap")
if not (ok_dap and ok_ui and ok_mdap) then
	return
end

-- 3. CONFIGURE UI
dapui.setup() -- The massive 40-line table you had was exactly the default!

dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

-- 4. CONFIGURE MASON-DAP
mason_dap.setup({
	ensure_installed = { "codelldb" },
	automatic_installation = true, -- <--- ADD THIS BACK
	handlers = { mason_dap.default_setup },
})

-- 5. KEYMAPS
local map = vim.keymap.set
map("n", "<leader>ds", dap.continue, { desc = "[D]ebug [S]tart/Continue" })
map("n", "<leader>di", dap.step_into, { desc = "[D]ebug Step [I]nto" })
map("n", "<leader>do", dap.step_over, { desc = "[D]ebug Step [O]ver" })
map("n", "<leader>dO", dap.step_out, { desc = "[D]ebug Step [O]ut" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "[D]ebug [B]reakpoint" })
map("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Condition: "))
end, { desc = "[D]ebug [B]reakpoint (Cond)" })
map("n", "<leader>du", dapui.toggle, { desc = "[D]ebug [U]I Toggle" })
map("n", "<leader>de", dapui.eval, { desc = "[D]ebug [E]val" })

-- 6. MANUAL CONFIGURATIONS
dap.configurations.cpp = {
	{
		name = "Launch file",
		type = "codelldb",
		request = "launch",
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		program = function()
			return vim.fn.input(
				"Path to executable: ",
				vim.fn.expand("%:p:h") .. "/" .. vim.fn.expand("%:t:r"),
				"file"
			)
		end,
	},
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.objc = dap.configurations.cpp
