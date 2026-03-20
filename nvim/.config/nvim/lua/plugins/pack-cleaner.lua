-- ========================================================================== --
--  CUSTOM SCRIPT: VIM.PACK CLEANER
-- ========================================================================== --

local function pack_clean()
	local unused_plugins = {}

	-- vim.pack.get() returns all plugins currently known to the package manager
	for _, plugin in ipairs(vim.pack.get()) do
		-- If the plugin hasn't been loaded in this session, flag it for deletion
		if not plugin.active then
			table.insert(unused_plugins, plugin.spec.name)
		end
	end

	-- Exit early if everything is active
	if #unused_plugins == 0 then
		vim.notify("No unused plugins found.", vim.log.levels.INFO)
		return
	end

	-- Prompt the user before deleting
	local prompt = "Remove "
		.. #unused_plugins
		.. " unused plugins?\n"
		.. table.concat(unused_plugins, ", ")
	local choice = vim.fn.confirm(prompt, "&Yes\n&No", 2)

	if choice == 1 then
		-- Delete them from the disk
		vim.pack.del(unused_plugins)
		vim.notify(
			"Cleaned up " .. #unused_plugins .. " plugins.",
			vim.log.levels.INFO
		)
	end
end

-- Map it to <leader>pc
vim.keymap.set("n", "<leader>pc", pack_clean, { desc = "[P]ack [C]lean" })
