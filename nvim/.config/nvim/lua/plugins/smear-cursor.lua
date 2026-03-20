-- ========================================================================== --
--  PLUGIN: SMEAR CURSOR
--  Animates the cursor with a smear effect (ghost trails).
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({ "https://github.com/sphamba/smear-cursor.nvim" })

-- 2. GUARD
local status, smear = pcall(require, "smear_cursor")
if not status then
	return
end

-- 3. CONFIGURE
smear.setup({})
