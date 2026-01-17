-- ========================================================================== --
--  NEOVIM ENTRY POINT (init.lua)
-- ========================================================================== --

-- 1. Load Core Configuration
--    We require these files first to ensure basic settings (like the Leader key)
--    are active before any plugins try to load or map keys.
require("config.options") -- Load options like line numbers, tabs, and mouse support
require("config.keymaps") -- Load global keybindings (Save, Quit, Explorer)

-- 2. CRITICAL: Load Infrastructure First
--    We MUST load LSP (which has Mason) before Debug (which needs Mason).
--    'require' caches modules, so the loop below won't reload them.
require("plugins.lsp")

-- 2. Automatic Plugin Loader
--    We define the path to the 'lua/plugins' directory where our modular files live.
--    This allows us to dynamically load every file in that folder.
local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"

--    We iterate over every item in that directory.
for file, type in vim.fs.dir(plugin_dir) do
	-- We check if the item is a file (not a folder) and ends with ".lua".
	if type == "file" and file:match("%.lua$") then
		-- We construct the module name required by Lua.
		-- Example: "telescope.lua" becomes "plugins.telescope"
		local module_name = "plugins." .. file:sub(1, -5)

		-- We load the file, executing its 'vim.pack.add' and 'setup' code.
		require(module_name)
	end
end
