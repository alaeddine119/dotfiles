-- ========================================================================== --
--  PLUGIN: TABOUT.NVIM
--  Supercharge your workflow by tabbing out of parentheses, quotes, etc.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({ "https://github.com/abecodes/tabout.nvim" })

-- 2. GUARD
local status, tabout = pcall(require, "tabout")
if not status then
	return
end

-- 3. CONFIGURE
tabout.setup({
	-- CRITICAL FOR BLINK.CMP:
	-- Blink uses custom floating windows, not the native 'pum'.
	-- By setting this to false, Blink controls <Tab> when the menu is open,
	-- and gracefully falls back to Tabout when the menu is closed.
	completion = false,

	-- We must provide the full list to append our custom `< >` rule
	tabouts = {
		{ open = "'", close = "'" },
		{ open = '"', close = '"' },
		{ open = "`", close = "`" },
		{ open = "(", close = ")" },
		{ open = "[", close = "]" },
		{ open = "{", close = "}" },
		{ open = "<", close = ">" }, -- Custom: Added for C++/Rust generics
	},
})
