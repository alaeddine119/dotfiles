-- ========================================================================== --
--  PLUGIN: RUSTACEANVIM
--  A supercharged Rust filetype plugin. Replaces standard LSP config for Rust.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/mrcjkb/rustaceanvim",
})

-- 2. CONFIGURE
--    Rustaceanvim looks for this global variable to configure itself.
--    We define it here so it is ready when you open a .rs file.
vim.g.rustaceanvim = {
	-- TOOLS (The extra commands)
	tools = {
		hover_actions = {
			auto_focus = true, -- Auto-focus the hover window
		},
	},

	-- SERVER (The LSP configuration)
	server = {
		on_attach = function(client, bufnr)
			-- Keymaps specific to Rust
			local map = vim.keymap.set

			-- Code Actions (Grouped better than standard LSP)
			map("n", "<leader>ca", function()
				vim.cmd.RustLsp("codeAction")
			end, { desc = "Rust: Code Action", buffer = bufnr })

			-- Debuggables (Auto-finds tests/main and runs debugger)
			map("n", "<leader>dr", function()
				vim.cmd.RustLsp("debuggables")
			end, { desc = "Rust: Debug Runnables", buffer = bufnr })

			-- Expand Macro (The killer feature)
			map("n", "<leader>em", function()
				vim.cmd.RustLsp("expandMacro")
			end, { desc = "Rust: Expand Macro", buffer = bufnr })

			-- Explain Error (Docs for the error under cursor)
			map("n", "<leader>ee", function()
				vim.cmd.RustLsp("explainError")
			end, { desc = "Rust: Explain Error", buffer = bufnr })

			-- Render Diagnostic (Pretty print error)
			map("n", "<leader>rd", function()
				vim.cmd.RustLsp("renderDiagnostic")
			end, { desc = "Rust: Render Diagnostic", buffer = bufnr })
		end,

		default_settings = {
			-- rust-analyzer settings
			["rust-analyzer"] = {
				cargo = {
					allFeatures = true,
				},
				checkOnSave = {
					command = "clippy",
				},
			},
		},
	},

	-- DAP (Debug Adapter)
	-- It will automatically detect 'codelldb' if Mason installed it.
	dap = {
		autoload_configurations = true,
	},
}
