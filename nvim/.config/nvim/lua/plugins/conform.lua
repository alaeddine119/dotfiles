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

		-- LUA
		lua = { "stylua" },

		-- RUST
		-- Use rustfmt, but allow fallback to LSP if rustfmt isn't found
		rust = { "rustfmt", lsp_format = "fallback" },

		-- Fallback for everything else
		["_"] = { "trim_whitespace" },
	},

	-- 4. FORMAT ON SAVE SETTINGS
	format_on_save = {
		timeout_ms = 1000, -- Biome is fast, but 1s is safe
		lsp_format = "fallback",
	},

	-- 5. NOTIFICATIONS
	notify_on_error = true,
})

-- 6. KEYMAPS
--    Manual format command: <Leader>f
vim.keymap.set("", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })
