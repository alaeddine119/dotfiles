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
-- Execute the current file based on file type
vim.keymap.set("n", "<leader>cx", function()
	vim.cmd("write")
	local ft = vim.bo.filetype
	local file = vim.fn.expand("%")
	local out = vim.fn.expand("%<")

	if ft == "cpp" then
		-- Cmd: Compile -> Run -> Wait
		-- We use 'printf' instead of 'echo' to avoid weird artifacts in the prompt
		local cmd = string.format(
			"if clang++ -std=c++20 '%s' -o '%s'; then ./'%s'; else echo '\n❌ Compilation Failed'; fi; echo ''; read -n 1 -s -r -p 'Press any key to close...'",
			file,
			out,
			out
		)

		require("snacks").terminal(cmd, {
			win = {
				position = "bottom",
				height = 0.3,
				border = "rounded",
				title = " Code Output ", -- <--- THIS FIXES THE CONFUSION
				title_pos = "center",
				style = "minimal",
			},
			interactive = true,
		})
	elseif ft == "lua" then
		vim.cmd("source %")
	elseif ft == "python" then
		local cmd = string.format(
			"python3 '%s'; echo ''; read -n 1 -s -r -p 'Press any key to close...'",
			file
		)
		require("snacks").terminal(cmd, {
			win = {
				position = "bottom",
				height = 0.3,
				title = " Python Output ",
				title_pos = "center",
			},
			interactive = true,
		})
	else
		vim.notify(
			"No execution command for filetype: " .. ft,
			vim.log.levels.WARN
		)
	end
end, { desc = "[C]ode E[x]ecute" })

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

-- -------------------------------------------------------------------------- --
--  Tiny Inline Diagnostic Toggle
-- -------------------------------------------------------------------------- --

-- Toggle the new inline diagnostics on/off
vim.keymap.set("n", "<leader>td", function()
	require("tiny-inline-diagnostic").toggle()
end, { desc = "[T]oggle [D]iagnostics (Inline)" })
