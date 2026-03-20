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

-- 5. MANUAL CONFIGURATIONS
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
