-- ========================================================================== --
--  PLUGIN: CONFORM.NVIM
--  Auto-formatting engine.
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
		-- JS/TS Stack explicitly routed to Biome
		javascript = { "biome" },
		typescript = { "biome" },
		javascriptreact = { "biome", "rustywind" },
		typescriptreact = { "biome", "rustywind" },

		-- Zero-config structural formats via Prettierd daemon
		json = { "prettierd" },
		jsonc = { "prettierd" },
		html = { "prettierd", "rustywind" },
		css = { "prettierd", "rustywind" },

		-- System Environments
		c = { "clang-format" },
		cpp = { "clang-format" },
		go = { "goimports", "gofmt" },
		lua = { "stylua" },
		rust = { "rustfmt", lsp_format = "fallback" },
		bash = { "shfmt" },
		sh = { "shfmt" },
		["_"] = { "trim_whitespace" },
	},

	-- 4. CUSTOMIZE FORMATTERS
	formatters = {
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
