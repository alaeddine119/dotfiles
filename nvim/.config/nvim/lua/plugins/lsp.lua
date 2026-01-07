-- ========================================================================== --
--  PLUGIN: LSP, MASON & AUTOCOMPLETE
-- ========================================================================== --

-- 1. Install all necessary plugins for LSP functionality.
vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig", -- Core LSP support for Neovim.
	"https://github.com/williamboman/mason.nvim", -- Package manager for external tools (LSPs, Formatters).
	"https://github.com/williamboman/mason-lspconfig.nvim", -- Bridges Mason and LSPConfig.
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim", -- Helper to auto-install a list of tools.
	"https://github.com/folke/lazydev.nvim", -- Improves Lua development (provides vim global types).
})

-- 2. Configure Diagnostic Visuals (How errors appear).
vim.diagnostic.config({
	virtual_text = false, -- Disable inline error text to keep code clean.
	virtual_lines = true, -- Enable multiline errors (requires lsp_lines plugin, else ignored).
	severity_sort = true, -- Sort diagnostics so Errors appear above Warnings.
	float = {
		border = "rounded", -- Use rounded borders for hover windows.
		source = "if_many", -- Show the source of the error only if there are multiple sources.
	},
	underline = {
		severity = vim.diagnostic.severity.ERROR, -- Only underline actual Errors, not warnings.
	},
})

-- 3. Setup LazyDev.
--    This injects the 'vim' global into the Lua LSP so you get completion for Neovim configs.
require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } }, -- Add support for libuv types.
	},
})

-- 4. Setup Mason (The external tool manager).
require("mason").setup()

--    Configure the automatic installer for Mason.
require("mason-tool-installer").setup({
	-- Ensure these specific tools are always installed.
	ensure_installed = {

		-- LSPs (Keep your existing ones)
		"lua_ls",
		"rust-analyzer",
		"tailwindcss-language-server",
		"typescript-language-server",
		"html-lsp",
		"css-lsp",
		"dockerfile-language-server",
		"biome",
		"rustywind",

		-- Formatters (Keep stylua)
		"stylua",

		-- LINTERS (Add these for nvim-lint)
		"hadolint", -- Docker Linter
		"htmlhint", -- HTML Linter
		"stylelint", -- CSS Linter
		"luacheck", -- Lua Linter
		"commitlint", -- Git Linter
	},
})

-- 5. Setup LSP Handlers.
--    This tells Mason-LSPConfig what to do when a server is ready.
require("mason-lspconfig").setup({
	handlers = {
		function(server_name)
			-- 1. Get the default capabilities from Neovim
			local capabilities = vim.lsp.protocol.make_client_capabilities()

			-- 2. Merge them with Blink.cmp capabilities (CRITICAL STEP)
			--    We use pcall just in case Blink isn't loaded yet
			local ok, blink = pcall(require, "blink.cmp")
			if ok then
				capabilities = blink.get_lsp_capabilities(capabilities)
			end

			-- SPECIAL SETUP: Biome
			if server_name == "biome" then
				require("lspconfig").biome.setup({
					capabilities = capabilities,
					-- Biome usually works from the root, but we can force it
					-- to look for biome.json if needed.
					root_dir = require("lspconfig.util").root_pattern("biome.json", "package.json", ".git"),
				})
				return -- Stop here so we don't run the default setup below
			end

			-- 3. Setup the server with these capabilities
			require("lspconfig")[server_name].setup({
				capabilities = capabilities,
			})
		end,
	},
})

-- 6. Configure behavior when an LSP attaches to a buffer.
--    This autocommand runs every time you open a file supported by an LSP.
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		-- Get the client object that just attached.
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		-- Enable Native Autocomplete if the server supports it.
		if client:supports_method("textDocument/completion") then
			-- Enable completion triggers (like typing '.').
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end

		-- Jump to the definition of the symbol under cursor.
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
			desc = "Go to [D]efinition",
			buffer = ev.buf,
		})

		-- Show documentation for the symbol under cursor (Hover).
		vim.keymap.set("n", "K", vim.lsp.buf.hover, {
			desc = "Hover Documentation",
			buffer = ev.buf,
		})
	end,
})

-- 7. Completion Options.
--    'noselect' prevents the menu from automatically selecting the first item (prevents accidental enters).
vim.cmd("set completeopt+=noselect")
