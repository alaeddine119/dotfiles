-- ========================================================================== --
--  CORE OPTIONS
-- ========================================================================== --

-- Set the global leader key to Space. This is the modifier for most custom commands.
-- NOTE: This MUST be set before any plugins are loaded, or they might use the default '\'.
vim.g.mapleader = " "

-- Set the local leader key to Space as well (used by some filetype-specific plugins).
vim.g.maplocalleader = " "

-- Indicate that we have a Nerd Font installed.
-- This allows plugins like nvim-web-devicons to render icons safely.
vim.g.have_nerd_font = true

-- Disable Netrw (We are using Oil.nvim instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- -------------------------------------------------------------------------- --
--  Visual Settings
-- -------------------------------------------------------------------------- --

-- Enable fat cursor
vim.o.guicursor = ""

-- Enable line numbers on the left side of the window.
vim.o.number = true

-- Enable relative line numbers (current line is 0, lines above/below are 1, 2, 3...).
-- This makes jumping to specific lines (e.g., '5j' or '10k') much easier.
vim.o.relativenumber = true

-- Always show the sign column (the gutter on the far left).
-- This prevents the text from shifting sideways when diagnostics/git signs appear.
vim.o.signcolumn = "yes"

-- Set the border style for floating windows (like LSP hover or diagnostics) to 'rounded'.
vim.o.winborder = "rounded"

-- Enable the cursorline (highlighting the line the cursor is on).
vim.o.cursorline = true

-- While typing a search command, show where the pattern, as it was typed so far, matches
vim.o.incsearch = true

-- Enables 24-bit RGB color in the `TUI`
vim.o.termguicolors = true

-- Screen column highlight 80 characters
vim.o.colorcolumn = "80"

-- Decrease update time (default is 4000ms).
-- Faster updates help plugins that rely on "CursorHold" events (like highlighting
-- the word under cursor or refreshing diagnostics).
vim.o.updatetime = 250

-- Decrease mapped sequence wait time (default is 1000ms).
-- Displays which-key / mini.clue popups faster when you stop typing.
vim.o.timeoutlen = 300

-- Scrolloff: Keep 8 lines of context above/below the cursor when scrolling.
-- This prevents the cursor from ever hitting the very bottom/top of the screen.
vim.o.scrolloff = 8

-- Split behavior: Force new splits to appear below or to the right.
-- (Default is above and left, which feels unnatural to most).
vim.o.splitright = true
vim.o.splitbelow = true

-- -------------------------------------------------------------------------- --
--  Tab & Indentation Settings
-- -------------------------------------------------------------------------- --

-- Set the visual width of a tab character to 4 spaces.
vim.o.tabstop = 4

-- Set the number of spaces inserted when you hit the Tab key.
vim.o.softtabstop = 4

-- Set the size of an indent (when using '>>', '<<', or auto-indenting).
vim.o.shiftwidth = 4

-- Convert actual tab characters to spaces. This ensures consistency across editors.
vim.o.expandtab = true

-- Do smart autoindenting when starting a new line
vim.o.smartindent = true

-- -------------------------------------------------------------------------- --
--  Behavior & Interaction
-- -------------------------------------------------------------------------- --

-- Enable mouse support in all modes (Normal, Insert, Visual, Command).
-- Useful for resizing splits or clicking tabs.
vim.o.mouse = "a"

-- Enable persistent undo.
-- This creates a file on disk that saves your undo history.
-- You can close Neovim, reopen a file hours later, and still undo previous edits.
vim.o.undofile = true

-- Enable confirmation dialogs.
-- If you try to quit with unsaved changes, Neovim will ask "Save changes?"
-- instead of just throwing an error.
vim.o.confirm = true

-- Configure the system clipboard.
-- We wrap this in `vim.schedule` to ensure it runs after the UI starts (prevents slow startup).
vim.schedule(function()
	-- 'unnamedplus' links Neovim's clipboard to the system clipboard (Ctrl+C / Ctrl+V).
	vim.o.clipboard = "unnamedplus"
end)

-- -------------------------------------------------------------------------- --
--  Autocommands
-- -------------------------------------------------------------------------- --

-- Create an autocommand to highlight text when it is yanked (copied).
vim.api.nvim_create_autocmd("TextYankPost", {
	-- Description of what this autocommand does (good for debugging).
	desc = "Highlight when yanking (copying) text",

	-- Assign it to a specific group so we can clear it easily if needed.
	group = vim.api.nvim_create_augroup(
		"kickstart-highlight-yank",
		{ clear = true }
	),

	-- The function to run when the event happens.
	callback = function()
		-- Use the built-in highlight function.
		vim.hl.on_yank()
	end,
})
