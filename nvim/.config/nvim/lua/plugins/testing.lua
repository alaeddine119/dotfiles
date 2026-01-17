-- ========================================================================== --
--  TESTING: Vim-Test + Vimux
-- ========================================================================== --

-- 1. Install Plugins
vim.pack.add({
	"https://github.com/vim-test/vim-test",
	"https://github.com/preservim/vimux",
})

-- 2. Configure Vim-Test to use Vimux
--    This tells vim-test: "Don't run in a builtin terminal, send text to Vimux"
vim.g["test#strategy"] = "vimux"

-- Optional: Configure Vimux to zoom the runner pane when there is an error
vim.g["VimuxZoomRunnerOnFailure"] = 0

-- Set Orientation to "h" (Horizontal split = Side-by-Side)
vim.g["VimuxOrientation"] = "h"

-- Optional: Width of the tmux pane (percentage)
vim.g["VimuxHeight"] = "35"

-- 3. Keymaps
local map = vim.keymap.set

-- Run the test nearest to the cursor (e.g., the specific function)
map("n", "<leader>tn", ":TestNearest<CR>", { desc = "[T]est [N]earest" })

-- Run the file
map("n", "<leader>tf", ":TestFile<CR>", { desc = "[T]est [F]ile" })

-- Run the whole suite
map("n", "<leader>ts", ":TestSuite<CR>", { desc = "[T]est [S]uite" })

-- Re-run the last test (very useful for TDD loops)
map("n", "<leader>tl", ":TestLast<CR>", { desc = "[T]est [L]ast" })

-- Visit the last test file (if you are deep in code and want to go back)
map("n", "<leader>tv", ":TestVisit<CR>", { desc = "[T]est [V]isit" })

-- Vimux specific: Inspect the runner pane (zooms into the tmux pane)
map(
	"n",
	"<leader>ti",
	":VimuxZoomRunner<CR>",
	{ desc = "[T]est [I]nspect Output" }
)
