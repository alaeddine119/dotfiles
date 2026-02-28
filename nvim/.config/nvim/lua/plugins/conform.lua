-- ========================================================================== --
--  PLUGIN: CONFORM.NVIM
--  Auto-formatting engine.
--  We are using BiomeJS for the entire web stack (JS, TS, HTML, CSS, JSON).
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

-- 2. GUARD
local status, conform = pcall(require, "conform")
if not status then
	return
end

-- 3. CONFIGURE
conform.setup({
	-- Define which formatters to use for which filetype
	formatters_by_ft = {
		-- WEB STACK: Biome handles all of this now
		javascript = { "biome" },
		typescript = { "biome" },
		javascriptreact = { "biome", "rustywind" },
		typescriptreact = { "biome", "rustywind" },
		json = { "biome" },
		jsonc = { "biome" },
		html = { "biome", "rustywind" },
		css = { "biome", "rustywind" },

		-- C/C++
		c = { "clang-format" },
		cpp = { "clang-format" },

		-- LUA
		lua = { "stylua" },

		-- RUST
		-- Use rustfmt, but allow fallback to LSP if rustfmt isn't found
		rust = { "rustfmt", lsp_format = "fallback" },

		-- BASH
		bash = { "shfmt" },
		sh = { "shfmt" },

		--Matlab
		matlab = { "mh_style" },

		-- Fallback for everything else
		["_"] = { "trim_whitespace" },
	},
	-- 4. CUSTOMIZE FORMATTERS (Force 80 char width)
	formatters = {
		biome = {
			-- This ensures Biome uses the config at the monorepo root
			require_cwd = true,
			-- Biome default is 80, but this forces it if a config file says otherwise
			prepend_args = {
				"format",
				"--indent-style",
				"space",
				"--indent-width",
				"2",
				"--line-width",
				"80",
			},
		},
		stylua = {
			-- Stylua default is often 120
			prepend_args = { "--column-width", "80" },
		},
		rustfmt = {
			-- Rustfmt default is 100
			prepend_args = { "--config", "max_width=80" },
		},
		shfmt = {
			-- "-i 4"  : Indent 4 spaces
			-- "-ci"   : Case indent (switch cases indented)
			-- "-bn"   : Binary ops (like &&, ||, |) start a new line
			prepend_args = { "-i", "4", "-ci", "-bn" },
		},
		["clang-format"] = {
			prepend_args = {
				"--style=file",
				"--fallback-style=LLVM",
			},
		},

		-- MATLAB Formatter (Miss Hit)
		-- In your formatters table:
		mh_style = {
			command = "uv",
			-- ADDED: '--from miss_hit' tells uv which package owns the command
			-- ADDED: '-q' ensures uv doesn't print download logs that break the file
			args = {
				"-q",
				"tool",
				"run",
				"--from",
				"miss_hit",
				"mh_style",
				"--fix",
				"$FILENAME",
			},
			stdin = false,
		},
	},

	-- 5. FORMAT ON SAVE SETTINGS
	format_on_save = {
		timeout_ms = 1000,
		lsp_format = "fallback",
	},

	-- 6. NOTIFICATIONS
	notify_on_error = true,
})

-- 6. KEYMAPS
--    Manual format command: <Leader>cf
vim.keymap.set("", "<leader>cf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[C]ode [F]ormat" })
