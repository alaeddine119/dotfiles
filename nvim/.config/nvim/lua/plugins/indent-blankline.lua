-- ========================================================================== --
--  PLUGIN: INDENT BLANKLINE
--  Adds indentation guides to all lines (including empty lines).
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
    "https://github.com/lukas-reineke/indent-blankline.nvim",
})

-- 2. GUARD
local status, ibl = pcall(require, "ibl")
if not status then
    return
end

-- 3. CONFIGURE
ibl.setup({})
