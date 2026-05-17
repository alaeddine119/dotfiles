-- ========================================================================== --
--  PLUGIN: LSP, MASON & AUTOCOMPLETE
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/williamboman/mason.nvim",
	"https://github.com/williamboman/mason-lspconfig.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	"https://github.com/folke/lazydev.nvim",
})

-- 2. DIAGNOSTICS & UI
vim.diagnostic.config({
	virtual_text = false,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
})

require("lazydev").setup()

-- 3. MASON
require("mason").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
		"tailwindcss-language-server",
		"html-lsp",
		"css-lsp",
		"dockerfile-language-server",
		"biome",
		"rustywind",
		"rust_analyzer",
		"vtsls",
		"eslint-lsp",
		"stylua",
		"hadolint",
		"htmlhint",
		"stylelint",
		"commitlint",
		"bash-language-server",
		"shfmt",
		"typos_lsp",
		"markdown_oxide",
	},
})

-- 4. CAPABILITIES
local caps = vim.lsp.protocol.make_client_capabilities()
local ok_blink, blink = pcall(require, "blink.cmp")
if ok_blink then
	caps = blink.get_lsp_capabilities(caps)
end

-- 5. HANDLERS
require("mason-lspconfig").setup({
	handlers = {
		function(server)
			-- Inject capabilities into the native config
			vim.lsp.config[server] = {
				capabilities = caps,
			}
			-- Natively start the server
			vim.lsp.enable(server)
		end,
	},
})

-- Manually setup ZLS (bypassing Mason)
vim.lsp.config["zls"] = {
	-- Neovim will automatically find this in ~/.local/bin/zls
	cmd = { "zls" },
	capabilities = caps,
}

vim.lsp.enable("zls")

-- 6. GLOBAL LSP ATTACH
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end

		local function map(keys, func, desc, mode)
			vim.keymap.set(
				mode or "n",
				keys,
				func,
				{ buffer = ev.buf, desc = desc }
			)
		end

		-- Core Navigation
		map("gd", function()
			Snacks.picker.lsp_definitions()
		end, "Definition")
		map("grr", function()
			Snacks.picker.lsp_references()
		end, "References")
		map("gri", function()
			Snacks.picker.lsp_implementations()
		end, "Implementation")
		map("grt", function()
			Snacks.picker.lsp_type_definitions()
		end, "Type Definition")
		map("gO", function()
			Snacks.picker.lsp_symbols()
		end, "Document Symbols")
		map("gW", function()
			Snacks.picker.lsp_workspace_symbols()
		end, "Workspace Symbols")

		-- Native Actions Override
		map("<leader>te", vim.diagnostic.open_float, "LSP Error Float")

		if client:supports_method("textDocument/codeLens") then
			map("grx", vim.lsp.codelens.run, "CodeLens")
		end

		if client:supports_method("textDocument/inlayHint") then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(
					not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
				)
			end, "LSP Inlay Hints")
			vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
		end
	end,
})

-- 7. NATIVE FORMATTING & ACTIONS (Zig)

-- Disable the default zig.vim formatting to prevent conflicts
vim.g.zig_fmt_parse_errors = 0
vim.g.zig_fmt_autosave = 0

-- Enable format-on-save natively via ZLS
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.zig", "*.zon" },
	callback = function(ev)
		-- 1. Format the file
		vim.lsp.buf.format({ bufnr = ev.buf })

		-- 2. Apply automatic fixes (like removing unused variables)
		vim.lsp.buf.code_action({
			context = { only = { "source.fixAll" } },
			apply = true,
		})
	end,
})
