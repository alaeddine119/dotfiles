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
		["_"] = { "trim_whitespace" },
	},

	-- 4. CUSTOMIZE FORMATTERS
	formatters = {
		biome = {
			require_cwd = false,
			-- Use a dynamic function to support projects with AND without biome.json
			args = function(self, ctx)
				-- 1. Search upwards from the current file for a biome config
				local has_config =
					vim.fs.find({ "biome.json", "biome.jsonc" }, {
						path = ctx.dirname,
						upward = true,
					})[1]

				if has_config then
					-- 2. If config exists, strictly use defaults and let biome.json dictate the rules
					return { "format", "--stdin-file-path", "$FILENAME" }
				end

				-- 3. If NO config exists, apply your custom fallback rules
				return {
					"format",
					"--stdin-file-path",
					"$FILENAME",
					"--indent-style",
					"space",
					"--indent-width",
					"2",
					"--line-width",
					"80",
				}
			end,
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
	},

	-- 5. FORMAT ON SAVE
	format_on_save = {
		timeout_ms = 1000,
		lsp_format = "fallback",
	},
})
