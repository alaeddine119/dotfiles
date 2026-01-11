-- ========================================================================== --
--  PLUGIN: TELESCOPE & HARPOON
-- ========================================================================== --

-- 1. Define a Build Hook for FZF-Native.
--    The 'telescope-fzf-native' plugin requires compilation (Make).
--    This autocommand detects when the plugin is installed/updated and runs 'make'.
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		-- Extract plugin name and action kind from event data.
		local name = ev.data.spec.name
		local kind = ev.data.kind

		-- Check if the modified plugin is fzf-native.
		if
			name == "telescope-fzf-native.nvim"
			and (kind == "install" or kind == "update")
		then
			print("Building fzf-native...")

			-- Execute the 'make' command in the plugin's directory.
			local result = vim.system({ "make" }, { cwd = ev.data.path }):wait()

			-- Check result and print status.
			if result.code == 0 then
				print("Successfully built fzf-native!")
			else
				print(
					"Failed to build fzf-native: "
						.. (result.stderr or "unknown error")
				)
			end
		end
	end,
})

-- 2. Install the Plugins.
vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim", -- Shared library required by Telescope/Harpoon.
	"https://github.com/nvim-tree/nvim-web-devicons", -- Icons library for file types.
	"https://github.com/nvim-telescope/telescope.nvim", -- The fuzzy finder itself.
	"https://github.com/nvim-telescope/telescope-ui-select.nvim", -- Improves UI for select menus (like code actions).

	-- FZF Native Sorter (C++ version for speed).
	-- We specify the name explicitly to match our build hook above.
	{
		src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
		name = "telescope-fzf-native.nvim",
	},

	-- Harpoon (File marking and quick navigation).
	{ src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
	"https://github.com/folke/trouble.nvim",
})

-- 3. Configure Telescope.
local telescope = require("telescope")
local trouble = require("trouble.sources.telescope") -- Import Trouble source
telescope.setup({
	defaults = {
		mappings = {
			i = { ["<c-t>"] = trouble.open }, -- Press Ctrl+t in Insert mode
			n = { ["<c-t>"] = trouble.open }, -- Press Ctrl+t in Normal mode
		},
	},
	extensions = {
		-- Configure the UI-Select extension to use the dropdown theme.
		["ui-select"] = {
			require("telescope.themes").get_dropdown(),
		},
	},
	pickers = {
		find_files = {
			theme = "ivy",
		},
	},
})

-- 4. Load Telescope Extensions.
--    We wrap these in pcall (protected call) to prevent errors if they aren't built yet.
pcall(telescope.load_extension, "fzf")
pcall(telescope.load_extension, "ui-select")
pcall(telescope.load_extension, "fidget")

-- 5. Configure Harpoon.
local harpoon = require("harpoon")
harpoon:setup()

-- 6. Helper Function: Open Harpoon inside Telescope.
--    This allows us to see our Harpoon marks in a nice fuzzy-finder window.
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
	local file_paths = {}
	-- Convert Harpoon items to a simple list of file paths.
	for _, item in ipairs(harpoon_files.items) do
		table.insert(file_paths, item.value)
	end

	-- Create a new Telescope picker.
	require("telescope.pickers")
		.new({}, {
			prompt_title = "Harpoon",
			finder = require("telescope.finders").new_table({
				results = file_paths,
			}),
			previewer = conf.file_previewer({}),
			sorter = conf.generic_sorter({}),
		})
		:find()
end

-- -------------------------------------------------------------------------- --
--  Keymaps: Telescope
-- -------------------------------------------------------------------------- --

local builtin = require("telescope.builtin")

-- Search for files in the current working directory.
vim.keymap.set(
	"n",
	"<leader>sf",
	builtin.find_files,
	{ desc = "[S]earch [F]iles" }
)

-- Search for text (Grep) inside all files in the directory.
vim.keymap.set(
	"n",
	"<leader>sg",
	builtin.live_grep,
	{ desc = "[S]earch via [G]rep" }
)

-- Search for the word currently under the cursor.
vim.keymap.set(
	"n",
	"<leader>sw",
	builtin.grep_string,
	{ desc = "[S]earch current [W]ord" }
)

-- Search through LSP diagnostics (errors/warnings).
vim.keymap.set(
	"n",
	"<leader>sd",
	builtin.diagnostics,
	{ desc = "[S]earch [D]iagnostics" }
)

-- Resume the last search (useful if you closed the window by accident).
vim.keymap.set(
	"n",
	"<leader>sr",
	builtin.resume,
	{ desc = "[S]earch [R]esume" }
)

-- Search recent files (oldfiles). '.' is used as a mnemonic for "recent".
vim.keymap.set(
	"n",
	"<leader>s.",
	builtin.oldfiles,
	{ desc = "[S]earch Recent Files [.]" }
)

-- Search Help tags (vim documentation).
vim.keymap.set(
	"n",
	"<leader>sh",
	builtin.help_tags,
	{ desc = "[S]earch [H]elp" }
)

-- Search Keymaps (shows what keys are mapped to what).
vim.keymap.set(
	"n",
	"<leader>sk",
	builtin.keymaps,
	{ desc = "[S]earch [K]eymaps" }
)

-- Search existing buffers
vim.keymap.set(
	"n",
	"<leader>sb",
	builtin.buffers,
	{ desc = "[S]earch [B]uffers" }
)

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set("n", "<leader>/", function()
	-- You can pass additional configuration to Telescope to change the theme, layout, etc.
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set("n", "<leader>s/", function()
	builtin.live_grep({
		grep_open_files = true,
		prompt_title = "[S]earch [/] Open Files",
	})
end, { desc = "[S]earch [/] in Open Files" })

-- Custom: Search files in the directory of the *current buffer* only.
-- This acts like a file explorer for the folder the current file is in.
vim.keymap.set("n", "<leader>se", function()
	builtin.find_files({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "[S]earch [E]xplorer (Current file dir)" })

-- Search notification history
vim.keymap.set("n", "<leader>sn", function()
	require("telescope").extensions.fidget.fidget()
end, { desc = "[S]earch [N]otifications" })

-- Search neovim config
vim.keymap.set("n", "<leader>sc", function()
	builtin.find_files({
		cwd = vim.fn.stdpath("config"),
	})
end, {
	desc = "[S]earch [C]onfig",
})

-- -------------------------------------------------------------------------- --
--  Keymaps: Harpoon
-- -------------------------------------------------------------------------- --

-- Add the current file to the Harpoon list.
vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end, { desc = "Harpoon: [A]dd File" })

-- Open the Harpoon quick menu (to visualize and edit marks).
vim.keymap.set("n", "<leader>e", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon: [E]dit Menu" })

-- Open the Harpoon list inside a Telescope window (using our helper function above).
vim.keymap.set("n", "<C-e>", function()
	toggle_telescope(harpoon:list())
end, { desc = "Harpoon: Telescope View" })

-- Quick Navigation: Alt + Shift + h/j/k/l
-- <M-H> stands for Alt+Shift+h
vim.keymap.set("n", "<M-H>", function()
	harpoon:list():select(1)
end, { desc = "Harpoon: File 1 [H]" })
vim.keymap.set("n", "<M-J>", function()
	harpoon:list():select(2)
end, { desc = "Harpoon: File 2 [J]" })
vim.keymap.set("n", "<M-K>", function()
	harpoon:list():select(3)
end, { desc = "Harpoon: File 3 [K]" })
vim.keymap.set("n", "<M-L>", function()
	harpoon:list():select(4)
end, { desc = "Harpoon: File 4 [L]" })

-- Cycle through Harpoon marks (Previous/Next).
vim.keymap.set("n", "<C-S-P>", function()
	harpoon:list():prev()
end, { desc = "Harpoon: [P]revious File" })
vim.keymap.set("n", "<C-S-N>", function()
	harpoon:list():next()
end, { desc = "Harpoon: [N]ext File" })
