-- ========================================================================== --
--  PLUGIN: PROJECT.NVIM
--  Auto-cd to project root and Telescope project switching
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/ahmedkhalf/project.nvim",
})

-- 2. GUARD
local status, project = pcall(require, "project_nvim")
if not status then
	return
end

-- 3. CONFIGURE
project.setup({
	manual_mode = false,
	detection_methods = { "pattern" },
	patterns = {
		".git",
		"Makefile",
		"package.json",
		"Cargo.toml",
		"CMakeLists.txt",
	},
	ignore_lsp = {},
	scope_chdir = "global",
	silent_chdir = true,
	show_hidden = true,
})

-- 4. TELESCOPE INTEGRATION (Safely Loaded)
-- Proper pcall structure so it doesn't crash during fresh installs
local tel_status, telescope = pcall(require, "telescope")
if tel_status then
	telescope.load_extension("projects")
end

-- 5. KEYMAPS
-- We wrap the require inside a function() so it ONLY looks for Telescope
-- when you actually press the keys, guaranteeing it's loaded by then.
vim.keymap.set("n", "<leader>sp", function()
	require("telescope").extensions.projects.projects({})
end, { desc = "[S]earch [P]rojects" })
