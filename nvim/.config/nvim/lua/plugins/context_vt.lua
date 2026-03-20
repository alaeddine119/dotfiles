-- ========================================================================== --
--  PLUGIN: NVIM_CONTEXT_VT
--  Shows virtual text at the end of blocks (fast, modern alternative to biscuits)
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({ "https://github.com/andersevenrud/nvim_context_vt" })

-- 2. GUARD
local ok, context_vt = pcall(require, "nvim_context_vt")
if not ok then
	return
end

-- 3. CONFIGURE (Relying 100% on native smart defaults)
context_vt.setup({})

-- 4. KEYMAPS (Tied to your Toggle prefix)
vim.keymap.set(
	"n",
	"<leader>tv",
	"<cmd>NvimContextVtToggle<CR>",
	{ desc = "Toggle [V]irtual Text Context" }
)
