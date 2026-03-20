-- ========================================================================== --
--  PLUGIN: RUSTACEANVIM
--  A supercharged Rust filetype plugin. Replaces standard LSP config for Rust.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({ "https://github.com/mrcjkb/rustaceanvim" })

-- 2. CONFIGURE
local caps = vim.lsp.protocol.make_client_capabilities()
local ok, blink = pcall(require, "blink.cmp")
if ok then
	caps = blink.get_lsp_capabilities(caps)
end

vim.g.rustaceanvim = {
	tools = {
		hover_actions = { auto_focus = true },
		float_win_config = {
			border = "rounded",
			auto_focus = true,
		},
	},
	server = {
		capabilities = caps,
		on_attach = function(_, bufnr)
			local map = function(keys, func, desc)
				vim.keymap.set(
					"n",
					keys,
					func,
					{ buffer = bufnr, desc = "Rust: " .. desc }
				)
			end

			map("<leader>dr", function()
				vim.cmd.RustLsp("debuggables")
			end, "[D]ebug [R]unnables")
			map("<leader>em", function()
				vim.cmd.RustLsp("expandMacro")
			end, "[E]xpand [M]acro")
			map("<leader>ee", function()
				vim.cmd.RustLsp("explainError")
			end, "[E]xplain [E]rror")
			map("<leader>rd", function()
				vim.cmd.RustLsp("renderDiagnostic")
			end, "[R]ender [D]iagnostic")

			vim.defer_fn(function()
				if vim.api.nvim_buf_is_valid(bufnr) then
					vim.cmd.RustLsp("flyCheck")
				end
			end, 10)
		end,
	},
	dap = { autoload_configurations = true },
}
