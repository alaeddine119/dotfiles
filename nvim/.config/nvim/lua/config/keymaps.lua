-- ========================================================================== --
--  GLOBAL KEYMAPS
-- ========================================================================== --

-- Move half page and center view
vim.keymap.set(
	"n",
	"<C-d>",
	"<C-d>zz",
	{ desc = "Scroll down and center cursor" }
)
vim.keymap.set(
	"n",
	"<C-u>",
	"<C-u>zz",
	{ desc = "Scroll up and center cursor" }
)

-- Keeps cursor in the middle when jumping to next search match
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search match (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search match (centered)" })

-- Map <leader>w to save the current file (:write).
-- This is faster than typing :w<Enter>.
vim.keymap.set("n", "<leader>w", ":write<CR>", { desc = "[W]rite File" })
vim.keymap.set("n", "<leader>q", ":quit<CR>", { desc = "[Q]uit Window" })

-- Map <leader>cx to source the current file (:source %)
vim.keymap.set(
	"n",
	"<leader>cx",
	":source %<CR>",
	{ desc = "[C]ode E[x]ecute (Source)" }
)

-- Map <leader><leader> to open the built-in file explorer (Netrw).
-- NOTE: This is now handled by lua/plugins/oil.lua (Replaces Netrw)
-- vim.keymap.set("n", "<leader><leader>", ":Ex<CR>", { desc = "Open File Explorer (Netrw)" })

-- Map Escape to clear search highlights.
-- By default, search results stay highlighted until you search for something else.
-- This allows you to press Esc to turn them off immediately.
vim.keymap.set(
	"n",
	"<Esc>",
	"<cmd>nohlsearch<CR>",
	{ desc = "Clear search highlights" }
)

-- -------------------------------------------------------------------------- --
--  Diagnostic Navigation
-- -------------------------------------------------------------------------- --

-- Map [d to go to the previous diagnostic message (error/warning).
-- We use count = -1 to move backward.
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev [D]iagnostic" })

-- Map ]d to go to the next diagnostic message.
-- We use count = 1 to move forward.
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next [D]iagnostic" })

-- -------------------------------------------------------------------------- --
--  Tiny Inline Diagnostic Toggle
-- -------------------------------------------------------------------------- --

-- Toggle the new inline diagnostics on/off
vim.keymap.set("n", "<leader>td", function()
	require("tiny-inline-diagnostic").toggle()
end, { desc = "[T]oggle [D]iagnostics (Inline)" })
