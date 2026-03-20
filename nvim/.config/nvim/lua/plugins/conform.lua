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
	formatters_by_ft = {
		javascript = { "biome" },
		typescript = { "biome" },
		javascriptreact = { "biome", "rustywind" },
		typescriptreact = { "biome", "rustywind" },
		json = { "biome" },
		jsonc = { "biome" },
		html = { "biome", "rustywind" },
		css = { "biome", "rustywind" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		lua = { "stylua" },
		rust = { "rustfmt", lsp_format = "fallback" },
		bash = { "shfmt" },
		sh = { "shfmt" },
		matlab = { "mh_style" },
		["_"] = { "trim_whitespace" },
	},

	-- 4. CUSTOMIZE FORMATTERS
	formatters = {
		biome = {
			require_cwd = false,
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
			prepend_args = { "--column-width", "80" },
		},
		rustfmt = {
			prepend_args = { "--config", "max_width=80" },
		},
		shfmt = {
			prepend_args = { "-i", "4", "-ci", "-bn" },
		},
		["clang-format"] = {
			prepend_args = { "--style=file", "--fallback-style=LLVM" },
		},
		mh_style = {
			command = "uv",
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

	-- 5. FORMAT ON SAVE
	format_on_save = {
		timeout_ms = 1000,
		lsp_format = "fallback",
	},
})
