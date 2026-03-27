-- ========================================================================== --
--  PLUGIN: BLINK.CMP
--  High-performance autocompletion engine.
-- ========================================================================== --

vim.pack.add({
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/rafamadriz/friendly-snippets",
})

-- Reads the current git tag downloaded by vim.pack to feed to Blink's downloader
local function get_blink_version()
	local blink_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/blink.cmp"
	if vim.fn.isdirectory(blink_path) == 0 then
		return nil
	end

	local obj = vim.system(
		{ "git", "describe", "--tags", "--abbrev=0" },
		{ text = true, cwd = blink_path }
	):wait()
	if obj.code == 0 and obj.stdout then
		return vim.trim(obj.stdout)
	end
	return "v1.10.1"
end

local status, blink = pcall(require, "blink.cmp")
if not status then
	return
end

blink.setup({
	fuzzy = {
		prebuilt_binaries = {
			download = true,
			force_version = get_blink_version(),
		},
	},

	keymap = {
		preset = "default",
		["<CR>"] = { "accept", "fallback" },
	},

	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "mono",
	},

	completion = {
		menu = { auto_show = true },
		ghost_text = { enabled = false },
		documentation = { auto_show = true, auto_show_delay_ms = 0 },
	},

	signature = { enabled = true, window = { border = "rounded" } },

	sources = {
		providers = {
			lsp = { score_offset = 1000 },
			path = { score_offset = 90 },
			snippets = { score_offset = 80 },
			-- buffer = { score_offset = 50 },
		},
	},
})
