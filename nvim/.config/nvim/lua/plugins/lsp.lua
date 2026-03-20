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
	"https://git.sr.ht/~chinmay/clangd_extensions.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/madskjeldgaard/cppman.nvim",
})

-- 2. DIAGNOSTICS & UI
vim.diagnostic.config({
	virtual_text = false,
	underline = true,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
})

require("lazydev").setup({
	library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
})

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
		"vtsls",
		"eslint-lsp",
		"matlab-language-server",
		"stylua",
		"hadolint",
		"htmlhint",
		"stylelint",
		"commitlint",
		"bash-language-server",
		"shfmt",
	},
})

-- 4. CAPABILITIES
local caps = vim.lsp.protocol.make_client_capabilities()
local ok_blink, blink = pcall(require, "blink.cmp")
if ok_blink then
	caps = blink.get_lsp_capabilities(caps)
end

-- 5. HANDLERS (Mason Bridge)
local lspconfig = require("lspconfig")
require("mason-lspconfig").setup({
	handlers = {
		function(server)
			local ignore = {
				rust_analyzer = 1,
				["rust-analyzer"] = 1,
				clangd = 1,
				ts_ls = 1,
				vtsls = 1,
				tailwindcss = 1,
				matlab_ls = 1,
			}
			if ignore[server] then
				return
			end

			local opts = { capabilities = caps }
			if server == "biome" then
				opts.root_dir = lspconfig.util.root_pattern(
					"biome.json",
					"package.json",
					".git"
				)
			end
			lspconfig[server].setup(opts)
		end,

		["vtsls"] = function()
			lspconfig.vtsls.setup({
				capabilities = caps,
				root_dir = lspconfig.util.root_pattern(
					"pnpm-workspace.yaml",
					"package.json",
					".git"
				),
				settings = {
					vtsls = {
						autoUseWorkspaceTsdk = true,
						experimental = {
							completion = { enableServerSideFuzzyMatch = true },
						},
					},
					typescript = {
						tsserver = { maxTsServerMemory = 8192 },
						preferences = { includePackageJsonAutoImports = "on" },
					},
				},
			})
		end,

		["tailwindcss"] = function()
			lspconfig.tailwindcss.setup({
				capabilities = caps,
				-- ONLY attach to these to stop "Unknown filetype" warnings
				filetypes = {
					"html",
					"css",
					"scss",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
				},
				settings = {
					tailwindCSS = {
						experimental = {
							classRegex = {
								{
									"cva\\(([^)]*)\\)",
									"[\"'`]([^\"'`]*)\"['`]",
								},
								{ "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*)\"['`]" },
							},
						},
					},
				},
			})
		end,

		["matlab_ls"] = function()
			lspconfig.matlab_ls.setup({
				capabilities = caps,
				settings = {
					MATLAB = {
						-- FIXED: Portable home directory
						installPath = vim.fn.expand("$HOME") .. "/.local",
						indexWorkspace = true,
						telemetry = false,
					},
				},
			})
		end,
	},
})

-- 6. CLANGD (Custom Robust Setup)
pcall(function()
	require("cppman").setup()
end)
if pcall(require, "clangd_extensions") then
	require("clangd_extensions").setup({
		inlay_hints = { inline = true, only_current_line = false },
	})
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp", "objc", "objcpp" },
	callback = function(ev)
		local root = vim.fs.root(
			ev.buf,
			{ "compile_commands.json", "compile_flags.txt", ".git" }
		)
		local flags = vim.bo[ev.buf].filetype == "c" and { "-std=c17" }
			or { "-std=c++23" }
		vim.lsp.start({
			name = "clangd",
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--completion-style=detailed",
				"--header-insertion=iwyu",
				"-j=4",
			},
			root_dir = root
				or vim.fs.dirname(vim.api.nvim_buf_get_name(ev.buf)),
			capabilities = caps,
			init_options = {
				usePlaceholders = true,
				completeUnimported = true,
				fallbackFlags = flags,
			},
		})
	end,
})

-- 7. GLOBAL LSP ATTACH (Keymaps & Logic)
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end -- Guard: Silences "need-check-nil" warnings

		local function map(keys, func, desc, mode)
			vim.keymap.set(
				mode or "n",
				keys,
				func,
				{ buffer = ev.buf, desc = "LSP: " .. desc }
			)
		end

		-- TABLE-DRIVEN MAPPINGS
		local standard_maps = {
			-- Navigating with Snacks
			{
				"gd",
				function()
					Snacks.picker.lsp_definitions()
				end,
				"Definition",
			},
			{
				"gr",
				function()
					Snacks.picker.lsp_references()
				end,
				"References",
			},
			{
				"gri",
				function()
					Snacks.picker.lsp_implementations()
				end,
				"Implementation",
			},
			{
				"grt",
				function()
					Snacks.picker.lsp_type_definitions()
				end,
				"Type Definition",
			},
			{
				"gO",
				function()
					Snacks.picker.lsp_symbols()
				end,
				"Document Symbols",
			},
			{
				"gW",
				function()
					Snacks.picker.lsp_workspace_symbols()
				end,
				"Workspace Symbols",
			},

			-- Native LSP Actions
			{ "grn", vim.lsp.buf.rename, "Rename" },
			{ "grD", vim.lsp.buf.declaration, "Declaration" },
			{ "K", vim.lsp.buf.hover, "Hover" },
			{ "<leader>te", vim.diagnostic.open_float, "Show Error" },
		}

		for _, m in ipairs(standard_maps) do
			map(m[1], m[2], m[3])
		end

		-- CODE ACTIONS (Special handling for Rust)
		if client.name == "rust_analyzer" then
			map("gra", function()
				vim.cmd.RustLsp("codeAction")
			end, "Code Action", { "n", "x" })
		else
			map("gra", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
		end

		-- INLAY HINTS
		if client:supports_method("textDocument/inlayHint") then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(
					not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
				)
			end, "Toggle Hints")
			vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
		end

		-- LANGUAGE SPECIFIC EXTRAS
		if client.name == "clangd" then
			map(
				"<leader>ch",
				"<cmd>ClangdSwitchSourceHeader<cr>",
				"Switch Header"
			)
			local ok_cp, cp = pcall(require, "cppman")
			if ok_cp then
				map("<leader>k", function()
					cp.open_cppman_for(vim.fn.expand("<cword>"))
				end, "Cppman")
			end
		end

		if client.name == "vtsls" then
			local function vts(c, title)
				return function()
					client:exec_cmd({
						title = title,
						command = "typescript." .. c,
						arguments = { vim.api.nvim_buf_get_name(ev.buf) },
					}, { bufnr = ev.buf })
				end
			end
			map(
				"<leader>co",
				vts("organizeImports", "Organize Imports"),
				"Organize"
			)
			map(
				"<leader>cM",
				vts("addMissingImports", "Add Missing"),
				"Missing"
			)
			map(
				"<leader>cu",
				vts("removeUnusedImports", "Remove Unused"),
				"Cleanup"
			)
		end
	end,
})
