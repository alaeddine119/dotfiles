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

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set(
	"t",
	"<Esc><Esc>",
	"<C-\\><C-n>",
	{ desc = "Exit terminal mode" }
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

-- ========================================================================== --
--  COMPILE MODE KEYMAPS
-- ========================================================================== --

-- <leader>cb -> [C]ompile [B]uild: Opens the prompt with your auto-detected command
vim.keymap.set(
	"n",
	"<leader>cb",
	"<cmd>Compile<CR>",
	{ desc = "[C]ompile [B]uild" }
)

-- <leader>cx -> [C]ompile e[X]ecute: Instantly re-runs the last command without prompting
vim.keymap.set(
	"n",
	"<leader>cx",
	"<cmd>Recompile<CR>",
	{ desc = "[C]ompile e[X]ecute (Rerun)" }
)

-- Navigate through compilation errors easily
vim.keymap.set(
	"n",
	"]e",
	"<cmd>NextError<CR>",
	{ desc = "Next compilation [E]rror" }
)
vim.keymap.set(
	"n",
	"[e",
	"<cmd>PrevError<CR>",
	{ desc = "Prev compilation [E]rror" }
)
