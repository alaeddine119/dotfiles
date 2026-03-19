-- ========================================================================== --
--  PLUGIN: BLINK.CMP
--  High-performance autocompletion engine.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/rafamadriz/friendly-snippets",
})

-- 2. DYNAMIC VERSION RESOLVER
-- Reads the current git tag downloaded by vim.pack to feed to Blink's downloader
local function get_blink_version()
	local blink_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/blink.cmp"
	if vim.fn.isdirectory(blink_path) == 0 then
		return nil
	end

	-- Ask git for the closest tag in the directory vim.pack just created
	local obj = vim.system(
		{ "git", "describe", "--tags", "--abbrev=0" },
		{ text = true, cwd = blink_path }
	):wait()

	if obj.code == 0 and obj.stdout then
		return vim.trim(obj.stdout)
	end

	-- Safe fallback to the latest known v1 tag if git is busy/locked during the first 0.1s
	return "v1.10.1"
end

-- 3. GUARD
local status, blink = pcall(require, "blink.cmp")
if not status then
	return
end

-- 4. CONFIGURE
blink.setup({
	-- THE FIX: Tell Blink exactly which binary to download, bypassing the git read error
	fuzzy = {
		prebuilt_binaries = {
			download = true,
			force_version = get_blink_version(),
		},
	},

	keymap = {
		preset = "none", -- We want full control
		["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-e>"] = { "hide", "fallback" },
		["<C-y>"] = { "select_and_accept" },

		-- Navigation
		["<C-n>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<Up>"] = { "select_prev", "fallback" },

		-- Accept with Enter
		["<CR>"] = { "accept", "fallback" },
	},

	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "mono",
	},

	completion = {
		menu = { auto_show = false },
		ghost_text = { enabled = true },
		documentation = { auto_show = true, auto_show_delay_ms = 0 },
	},

	signature = { enabled = true },

	-- PRIORITY CONFIGURATION
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },

		providers = {
			lsp = {
				name = "LSP",
				module = "blink.cmp.sources.lsp",
				score_offset = 1000, -- Boost LSP suggestions
			},
			snippets = {
				name = "Snippets",
				module = "blink.cmp.sources.snippets",
				score_offset = 80, -- Lower priority for snippets
			},
			path = {
				name = "Path",
				module = "blink.cmp.sources.path",
				score_offset = 90,
			},
			buffer = {
				name = "Buffer",
				module = "blink.cmp.sources.buffer",
				score_offset = 50, -- Lowest priority for random words in file
			},
		},
	},
})
