-- ========================================================================== --
--  GLOBAL KEYMAPS
-- ========================================================================== --

-- Move half page and center view
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center cursor" })
-- Keeps cursor in the middle when jumping to next search match
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Map <leader>w to save the current file (:write).
-- This is faster than typing :w<Enter>.
vim.keymap.set("n", "<leader>w", ":write<CR>", { desc = "Save File" })

-- Map <leader>q to quit the current window (:quit).
vim.keymap.set("n", "<leader>q", ":quit<CR>", { desc = "Quit Neovim" })
-- Map <leader>x to save and quit (:x)
vim.keymap.set("n", "<leader>x", ":x<CR>", { desc = "Save and Quit" })
-- Map <leader>so to source the current file (:source %)
vim.keymap.set("n", "<leader>so", ":source %<CR>", { desc = "Source Current File" })

-- Map <leader><leader> to open the built-in file explorer (Netrw).
-- NOTE: This is now handled by lua/plugins/oil.lua (Replaces Netrw)
-- vim.keymap.set("n", "<leader><leader>", ":Ex<CR>", { desc = "Open File Explorer (Netrw)" })

-- Map Escape to clear search highlights.
-- By default, search results stay highlighted until you search for something else.
-- This allows you to press Esc to turn them off immediately.
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- -------------------------------------------------------------------------- --
--  Diagnostic Navigation
-- -------------------------------------------------------------------------- --

-- Map [d to go to the previous diagnostic message (error/warning).
-- We use count = -1 to move backward.
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous [D]iagnostic message" })

-- Map ]d to go to the next diagnostic message.
-- We use count = 1 to move forward.
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next [D]iagnostic message" })
