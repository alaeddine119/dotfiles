-- ========================================================================== --
--  PLUGIN: TINY INLINE DIAGNOSTIC
--  Replaces default virtual text with pretty, wrapping inline diagnostics.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({ "https://github.com/rachartier/tiny-inline-diagnostic.nvim" })

-- 2. GUARD
local ok, tiny = pcall(require, "tiny-inline-diagnostic")
if not ok then
	return
end

-- 3. CONFIGURE
tiny.setup({
	preset = "modern",
	options = {
		show_source = { enabled = true, if_many = true },
		throttle = 20,
		overflow = { mode = "wrap" },
		multilines = { enabled = true, always_show = true },
		break_line = { enabled = true, after = 80 }, -- Fixed: matched comment to value
		show_code = true,
	},
})

-- 4. INTEGRATION
vim.diagnostic.config({ virtual_text = false })
vim.keymap.set(
	"n",
	"<leader>td",
	tiny.toggle,
	{ desc = "Toggle Inline Diagnostics" }
)
