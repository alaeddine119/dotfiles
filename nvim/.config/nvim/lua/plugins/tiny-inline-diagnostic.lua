-- ========================================================================== --
--  PLUGIN: TINY INLINE DIAGNOSTIC
--  Replaces default virtual text with pretty, wrapping inline diagnostics.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/rachartier/tiny-inline-diagnostic.nvim",
})

-- 2. GUARD
local status, tiny = pcall(require, "tiny-inline-diagnostic")
if not status then
	return
end

-- 3. CONFIGURE
tiny.setup({
	-- Style preset (modern, classic, minimal, powerline, ghost, amongus)
	preset = "modern",

	options = {
		-- Show the source (e.g., "rust-analyzer") next to the error
		show_source = {
			enabled = true,
			if_many = true,
		},

		-- Throttle updates for performance (ms)
		throttle = 20,

		-- WRAPPING SETTINGS (Solves your main issue)
		overflow = {
			mode = "wrap", -- Wrap long lines instead of truncating them
		},

		-- Multiline diagnostic support
		multilines = {
			enabled = true,
			always_show = true,
		},

		-- Break long messages into separate lines automatically
		break_line = {
			enabled = true,
			after = 80, -- Wrap after 80 chars
		},

		-- If you want to see the error code (e.g. E501)
		show_code = true,
	},

	-- Custom Highlights (Optional, matches your Rose Pine theme roughly)
	-- The plugin usually auto-detects colors from your theme's Diagnostic groups.
})

-- 4. DISABLE NATIVE VIRTUAL TEXT
-- This plugin renders its own text, so we must disable Neovim's built-in one.
vim.diagnostic.config({ virtual_text = false })

-- 5. KEYMAPS
vim.keymap.set("n", "<leader>td", function()
	tiny.toggle()
end, { desc = "[T]oggle [D]iagnostics (Inline)" })
