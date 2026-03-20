-- ========================================================================== --
--  PLUGIN: TELESCOPE & HARPOON
-- ========================================================================== --

-- 1. BUILD HOOK (FZF-Native)
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local s = ev.data.spec
		if
			s.name == "telescope-fzf-native.nvim"
			and (ev.data.kind == "install" or ev.data.kind == "update")
		then
			print("Building fzf-native...")
			vim.system({ "make" }, { cwd = ev.data.path }):wait()
		end
	end,
})

-- 2. INSTALL
vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-telescope/telescope-ui-select.nvim",
	{
		src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
		name = "telescope-fzf-native.nvim",
	},
	{ src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
})

-- 3. CONFIGURE TELESCOPE
local telescope = require("telescope")
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")

telescope.setup({
	defaults = {
		mappings = {
			i = {
				["<c-t>"] = function()
					require("trouble.sources.telescope").open()
				end,
			},
		},
		file_ignore_patterns = {
			"node_modules",
			".next/",
			".git/",
			"dist/",
			"build/",
			"target/",
		},
	},
	extensions = { ["ui-select"] = { themes.get_dropdown() } },
	pickers = {
		find_files = { theme = "ivy", hidden = true },
		live_grep = { additional_args = { "--hidden" } },
	},
})

pcall(telescope.load_extension, "fzf")
pcall(telescope.load_extension, "ui-select")

-- 4. HARPOON SETUP & INTEGRATION
local harpoon = require("harpoon")
harpoon:setup()

local function toggle_harpoon_telescope(harpoon_files)
	local paths = {}
	for _, item in ipairs(harpoon_files.items) do
		table.insert(paths, item.value)
	end
	require("telescope.pickers")
		.new({}, {
			prompt_title = "Harpoon",
			finder = require("telescope.finders").new_table({ results = paths }),
			previewer = require("telescope.config").values.file_previewer({}),
			sorter = require("telescope.config").values.generic_sorter({}),
		})
		:find()
end

-- 5. KEYMAPS: SEARCH
local map = function(keys, func, desc)
	vim.keymap.set("n", keys, func, { desc = desc })
end
map("<leader>sf", builtin.find_files, "[S]earch [F]iles")
map("<leader>sg", builtin.live_grep, "[S]earch [G]rep")
map("<leader>sw", builtin.grep_string, "[S]earch [W]ord")
map("<leader>sd", builtin.diagnostics, "[S]earch [D]iagnostics")
map("<leader>sr", builtin.resume, "[S]earch [R]esume")
map("<leader>s.", builtin.oldfiles, "[S]earch Recent")
map("<leader>sh", builtin.help_tags, "[S]earch [H]elp")
map("<leader>sk", builtin.keymaps, "[S]earch [K]eymaps")
map("<leader>sb", builtin.buffers, "[S]earch [B]uffers")
map("<leader>/", function()
	builtin.current_buffer_fuzzy_find(
		themes.get_dropdown({ winblend = 10, previewer = false })
	)
end, "[/] Fuzzily search buffer")
map("<leader>s/", function()
	builtin.live_grep({
		grep_open_files = true,
		prompt_title = "Search Open Files",
	})
end, "[S]earch Open Files")
map("<leader>se", function()
	builtin.find_files({ cwd = vim.fn.expand("%:p:h") })
end, "[S]earch [E]xplorer (Dir)")
map("<leader>sc", function()
	builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, "[S]earch [C]onfig")

-- 6. KEYMAPS: HARPOON
map("<leader>a", function()
	harpoon:list():add()
end, "Harpoon [A]dd")
map("<leader>e", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, "Harpoon [E]dit")
map("<C-e>", function()
	toggle_harpoon_telescope(harpoon:list())
end, "Harpoon Telescope")
map("<M-a>", function()
	harpoon:list():select(1)
end, "Harpoon 1")
map("<M-s>", function()
	harpoon:list():select(2)
end, "Harpoon 2")
map("<M-d>", function()
	harpoon:list():select(3)
end, "Harpoon 3")
map("<M-f>", function()
	harpoon:list():select(4)
end, "Harpoon 4")
map("<C-S-P>", function()
	harpoon:list():prev()
end, "Harpoon [P]rev")
map("<C-S-N>", function()
	harpoon:list():next()
end, "Harpoon [N]ext")

-- 7. TMUX SESSION SWITCHER
map("<leader>st", function()
	local state = require("telescope.actions.state")
	require("telescope.pickers")
		.new({}, {
			prompt_title = "Tmux Sessions",
			finder = require("telescope.finders").new_oneshot_job(
				{ "tmux", "list-sessions", "-F", "#S" },
				{}
			),
			sorter = require("telescope.config").values.generic_sorter({}),
			attach_mappings = function(buf, _)
				actions.select_default:replace(function()
					local selection = state.get_selected_entry()
					actions.close(buf)
					if selection then
						vim.schedule(function()
							vim.fn.system(
								"tmux switch-client -t " .. selection[1]
							)
						end)
					end
				end)
				return true
			end,
		})
		:find()
end, "[S]earch [T]mux Sessions")
