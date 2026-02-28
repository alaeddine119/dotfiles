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
	"https://git.sr.ht/~chinmay/clangd_extensions.nvim", --
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/madskjeldgaard/cppman.nvim",
})

-- 2. Configure Diagnostic Visuals (How errors appear).
vim.diagnostic.config({
	virtual_text = false, -- Disable inline error text to keep code clean.
	virtual_lines = false, -- Enable multiline errors (requires lsp_lines plugin, else ignored).
	underline = true, -- Enable underline (the subtle hint)
	severity_sort = true, -- Sort diagnostics so Errors appear above Warnings.
	float = {
		border = "rounded", -- Use rounded borders for hover windows.
		source = "if_many", -- Show the source of the error only if there are multiple sources.
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
		"vtsls", -- Better version of typescript-language-server for monorepos
		"tailwindcss-language-server",
		"eslint-lsp",
		"matlab-language-server",

		-- Formatters (Keep stylua)
		"stylua",

		-- LINTERS (Add these for nvim-lint)
		"hadolint", -- Docker Linter
		"htmlhint", -- HTML Linter
		"stylelint", -- CSS Linter
		"commitlint", -- Git Linter
		"bash-language-server", -- Bash LSP
		"shfmt", -- Bash formatter
	},
})

-- 5. Setup LSP Handlers.
--    This tells Mason-LSPConfig what to do when a server is ready.

-- DEFINE CAPABILITIES (Shared between Mason and System LSPs)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, blink = pcall(require, "blink.cmp")
if ok then
	capabilities = blink.get_lsp_capabilities(capabilities)
end

-- Force documentation support for ALL servers (System + Mason)
capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = { "documentation", "detail", "additionalTextEdits" },
}

require("mason-lspconfig").setup({
	handlers = {
		function(server_name)
			-- Add these exact strings to the ignore list
			local ignore_list = {
				"rust_analyzer",
				"rust-analyzer",
				"clangd",
				"tsserver", -- Old name
				"typescript-language-server", -- New name
				"ts_ls",
			}

			for _, name in ipairs(ignore_list) do
				if server_name == name then
					return
				end
			end

			-- SPECIAL SETUP: Biome
			if server_name == "biome" then
				require("lspconfig").biome.setup({
					capabilities = capabilities,
					-- Biome usually works from the root, but we can force it
					-- to look for biome.json if needed.
					root_dir = require("lspconfig.util").root_pattern(
						"biome.json",
						"package.json",
						".git"
					),
				})
				return -- Stop here so we don't run the default setup below
			end

			-- 3. Setup the server with these capabilities
			require("lspconfig")[server_name].setup({
				capabilities = capabilities,
			})
		end,

		["vtsls"] = function()
			require("lspconfig").vtsls.setup({
				capabilities = capabilities,
				-- Use a function to ensure we find the absolute root
				root_dir = function(fname)
					local util = require("lspconfig.util")
					return util.root_pattern(
						"pnpm-workspace.yaml",
						"turbo.json",
						".git"
					)(fname) or util.fs.dirname(fname)
				end,
				settings = {
					vtsls = {
						experimental = {
							completion = { enableServerSideFuzzyMatch = true },
						},
						autoUseWorkspaceTsdk = true,
					},
					typescript = {
						-- This is the critical setting for monorepos
						tsserver = {
							maxTsServerMemory = 8192,
						},
						preferences = {
							includePackageJsonAutoImports = "on",
						},
					},
				},
			})
		end,

		["tailwindcss"] = function()
			require("lspconfig").tailwindcss.setup({
				capabilities = capabilities,
				filetypes = {
					"html",
					"css",
					"javascriptreact",
					"typescriptreact",
					"javascript",
					"typescript",
				},
				settings = {
					tailwindCSS = {
						experimental = {
							classRegex = {
								{
									"cva\\(([^)]*)\\)",
									"[\"'`]([^\"'`]*)\"['`]",
								},
								{ "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*)\"['`]" }, -- For shadcn/ui
							},
						},
					},
				},
			})
		end,
		["matlab_ls"] = function()
			require("lspconfig").matlab_ls.setup({
				capabilities = capabilities,
				settings = {
					MATLAB = {
						-- This MUST point to the folder containing the dummy 'matlab' script
						installPath = "/home/alaeddine/.local",
						indexWorkspace = true,
						telemetry = false,
					},
				},
				single_file_support = true,
			})
		end,
	},
})

-- ========================================================================== --
--  7. ROBUST C/C++ SETUP (The "Out of the Box" Fix)
-- ========================================================================== --
-- PLUGIN INITIALIZATION
local ok_cppman, cppman = pcall(require, "cppman")
if ok_cppman then
	cppman.setup()
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp", "objc", "objcpp" },
	callback = function(ev)
		local current_file_dir =
			vim.fs.dirname(vim.api.nvim_buf_get_name(ev.buf))
		local project_root = vim.fs.root(ev.buf, {
			"compile_commands.json",
			"compile_flags.txt",
			".git",
		})

		-- DYNAMIC FALLBACK FLAGS
		-- Check the filetype to determine which standard to use
		local filetype = vim.bo[ev.buf].filetype
		local fallback_flags = {}

		if filetype == "c" or filetype == "objc" then
			fallback_flags = { "-std=c17" } -- Use C17 for .c files
		else
			fallback_flags = { "-std=c++23" } -- Use C++23 for .cpp files
		end

		vim.lsp.start({
			name = "clangd",
			cmd = {
				"clangd",
				-- 1. Indexing & Tidy
				"--background-index",
				"--clang-tidy",

				-- 2. Completion Behavior
				"--completion-style=detailed",
				"--header-insertion=iwyu",
				"--all-scopes-completion",
				"--completion-parse=auto",

				-- 3. Formatting & Snippets
				"--fallback-style=llvm",
				"--function-arg-placeholders",

				-- 4. Performance Boosters
				"-j=4",
				"--pch-storage=memory",
			},
			root_dir = project_root or current_file_dir,
			capabilities = capabilities,
			init_options = {
				usePlaceholders = true,
				completeUnimported = true,
				clangdFileStatus = true,
				-- FIXED: Now uses the correct flag based on filetype
				fallbackFlags = fallback_flags,
			},
		})
	end,
})

-- ========================================================================== --
--  8. Global LSP Keymaps (LspAttach)
-- ========================================================================== --

-- 6. Configure behavior when an LSP attaches to a buffer.
--    This autocommand runs every time you open a file supported by an LSP.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup(
		"kickstart-lsp-attach",
		{ clear = true }
	),
	callback = function(ev)
		-- NOTE: Remember that Lua is a real programming language, and as such it is possible
		-- to define small helper and utility functions so you don't have to repeat yourself.
		--
		-- In this case, we create a function that lets us more easily define mappings specific
		-- for LSP related items. It sets the mode, buffer and description for us each time.
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(
				mode,
				keys,
				func,
				{ buffer = ev.buf, desc = "LSP: " .. desc }
			)
		end

		-- Jump to the definition of the symbol under cursor.
		--  This is where a variable was first declared, or where a function is defined, etc.
		--  To jump back, press <C-t>.
		map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")

		-- Find references for the word under your cursor.
		map(
			"grr",
			require("telescope.builtin").lsp_references,
			"[G]oto [R]eferences"
		)

		-- Jump to the implementation of the word under your cursor.
		--  Useful when your language has ways of declaring types without an actual implementation.
		map(
			"gri",
			require("telescope.builtin").lsp_implementations,
			"[G]oto [I]mplementation"
		)

		-- Jump to the type of the word under your cursor.
		--  Useful when you're not sure what type a variable is and you want to see
		--  the definition of its *type*, not where it was *defined*.
		map(
			"grt",
			require("telescope.builtin").lsp_type_definitions,
			"[G]oto [T]ype Definition"
		)

		-- Fuzzy find all the symbols in your current document.
		--  Symbols are things like variables, functions, types, etc.
		map(
			"gO",
			require("telescope.builtin").lsp_document_symbols,
			"[D]ocument Symbols"
		)

		-- Fuzzy find all the symbols in your current workspace.
		--  Similar to document symbols, except searches over your entire project.
		map(
			"gW",
			require("telescope.builtin").lsp_dynamic_workspace_symbols,
			"[W]orkspace Symbols"
		)

		-- Rename the variable under your cursor.
		--  Most Language Servers support renaming across files, etc.
		map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

		-- Execute a code action, usually your cursor needs to be on top of an error
		-- or a suggestion from your LSP for this to activate.
		map("gra", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

		-- WARN: This is not Goto Definition, this is Goto Declaration.
		--  For example, in C this would take you to the header.
		map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

		-- Show doumentation for the symbol under cursor (Hover).
		map("K", vim.lsp.buf.hover, "Hover Documentation")

		-- Get the client object that just attached.
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		-- [FIX] Safety check: ensure client exists before using it
		if not client then
			return
		end

		-- SHOW ERROR: Open a floating window with the error message
		map("<leader>te", vim.diagnostic.open_float, "Show [E]rror message")

		-- The following code creates a keymap to toggle inlay hints in your
		-- code, if the language server you are using supports them
		--
		-- This may be unwanted, since they displace some of your code
		if client:supports_method("textDocument/inlayHint") then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(
					not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
				)
			end, "[T]oggle Inlay [H]ints")
		end

		-- Clangd-specific enhancements
		-- Clangd-specific enhancements
		if client and client.name == "clangd" then
			-- 1. Check for cppman ONCE at the start of the block
			local has_cppman, cp = pcall(require, "cppman")

			-- 2. Standard Clangd Mappings
			map(
				"<leader>ch",
				"<cmd>ClangdSwitchSourceHeader<cr>",
				"Switch Header/Source"
			)
			map("<leader>cht", "<cmd>ClangdTypeHierarchy<cr>", "Type Hierarchy")
			map("<leader>chc", "<cmd>ClangdCallHierarchy<cr>", "Call Hierarchy")
			map("<leader>ca", "<cmd>ClangdAST<cr>", "Clangd AST View")
			map("<leader>ci", "<cmd>ClangdSymbolInfo<cr>", "Clangd Symbol Info")

			-- 3. Cppman Mappings (using the 'cp' variable we defined above)
			if has_cppman then
				map("<leader>k", function()
					cp.open_cppman_for(vim.fn.expand("<cword>"))
				end, "Open Cppman Manual")
				map("<leader>cm", function()
					cp.open_cppman_for(vim.fn.expand("<cword>"))
				end, "Cppman Manual (Hover)")
				map("<leader>cc", function()
					cp.input()
				end, "Cppman Search Box")
			end
		end
	end,
})
