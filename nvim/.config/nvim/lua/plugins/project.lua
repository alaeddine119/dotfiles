vim.pack.add({ "https://github.com/ahmedkhalf/project.nvim" })
local status, project = pcall(require, "project_nvim")
if not status then
	return
end

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
