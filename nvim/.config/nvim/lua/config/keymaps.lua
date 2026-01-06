-- ========================================================================== --
--  GLOBAL KEYMAPS
-- ========================================================================== --

-- Map <leader>w to save the current file (:write).
-- This is faster than typing :w<Enter>.
vim.keymap.set("n", "<leader>w", ":write<CR>", { desc = "Save File" })

-- Map <leader>q to quit the current window (:quit).
vim.keymap.set("n", "<leader>q", ":quit<CR>", { desc = "Quit Neovim" })

-- Map <leader><space> to open the built-in file explorer (Netrw).
-- :Ex opens the explorer in the current buffer directory.
vim.keymap.set("n", "<leader><leader>", ":Ex<CR>", { desc = "Open File Explorer (Netrw)" })

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
