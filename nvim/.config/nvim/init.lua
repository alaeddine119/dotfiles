-- 1. CORE CONFIGURATION
-- Ensure Leader is set in options/keymaps before plugins load
require("config.options")
require("config.keymaps")

-- 2. PRIORITY PLUGINS
-- We boot these manually to ensure the UI looks right and LSP is ready immediately
local priority = { "colorscheme", "lsp" }
for _, name in ipairs(priority) do
	require("plugins." .. name)
end

-- 3. DYNAMIC PLUGIN LOADER
local plugin_path = vim.fn.stdpath("config") .. "/lua/plugins"

for file, type in vim.fs.dir(plugin_path) do
	local name = file:sub(1, -5) -- Remove '.lua'

	-- Only load files, and skip the ones we already loaded in Step 2
	if
		type == "file"
		and file:match("%.lua$")
		and name ~= "colorscheme"
		and name ~= "lsp"
	then
		local ok, err = pcall(require, "plugins." .. name)
		if not ok then
			vim.notify(
				"Error loading " .. name .. ":\n" .. err,
				vim.log.levels.ERROR
			)
		end
	end
end
