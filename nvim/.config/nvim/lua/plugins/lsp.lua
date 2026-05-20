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
		"html-lsp", -- VS Code HTML Server (Provides diagnostics)
		"css-lsp", -- VS Code CSS Server (Provides diagnostics)
		"json-lsp", -- VS Code JSON Server (Provides diagnostics)
		"dockerfile-language-server",
		"biome", -- Used exclusively for JS/TS stack natively
		"rustywind",
		"rust_analyzer",
		"vtsls",
		"gopls",
		"goimports",
		"eslint-lsp",
		"stylua",
		"prettierd", -- Zero-config ultra-fast markup formatting daemon
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
			local config = {
				capabilities = caps,
			}

			vim.lsp.config[server] = config
			vim.lsp.enable(server)
		end,
	},
})

-- Manually setup ZLS (bypassing Mason)
vim.lsp.config["zls"] = {
	cmd = { "zls" },
	capabilities = caps,
}
vim.lsp.enable("zls")

-- Global Augroups for automation loops
local highlight_augroup =
	vim.api.nvim_create_augroup("lsp-highlight", { clear = true })
local detach_augroup =
	vim.api.nvim_create_augroup("lsp-detach", { clear = true })

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
		map("gd", Snacks.picker.lsp_definitions, "Definition")
		map("grr", Snacks.picker.lsp_references, "References")
		map("gri", Snacks.picker.lsp_implementations, "Implementation")
		map("grt", Snacks.picker.lsp_type_definitions, "Type Definition")
		map("gO", Snacks.picker.lsp_symbols, "Document Symbols")
		map("gW", Snacks.picker.lsp_workspace_symbols, "Workspace Symbols")

		-- Native Actions Override
		map("<leader>te", function()
			vim.diagnostic.open_float()
		end, "LSP Error Float")

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

		-- Symbol Highlighting on Hover
		if client:supports_method("textDocument/documentHighlight", ev.buf) then
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = ev.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = ev.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})
		end

		-- Clean up highlights when LSP detaches
		vim.api.nvim_create_autocmd("LspDetach", {
			buffer = ev.buf,
			group = detach_augroup,
			callback = function(event2)
				vim.lsp.buf.clear_references()
				vim.api.nvim_clear_autocmds({
					group = highlight_augroup,
					buffer = event2.buf,
				})
			end,
		})
	end,
})

-- 7. NATIVE FORMATTING & ACTIONS (Zig)
vim.g.zig_fmt_parse_errors = 0
vim.g.zig_fmt_autosave = 0

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.zig", "*.zon" },
	callback = function(ev)
		vim.lsp.buf.format({ bufnr = ev.buf })
		vim.lsp.buf.code_action({
			context = {
				only = { "source.fixAll" },
				diagnostics = {}, -- 💡 Fix: Add this empty table to satisfy the strict LSP type requirement
			},
			apply = true,
		})
	end,
})
