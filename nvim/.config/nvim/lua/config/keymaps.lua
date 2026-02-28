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
-- Helper function to read compile_flags.txt if it exists
local function get_compile_flags(default_flags)
	local f = io.open("compile_flags.txt", "r")
	if f then
		local content = f:read("*a")
		f:close()
		-- Replace newlines with spaces to form a single command string
		local flags = content:gsub("\n", " ")
		return flags
	end
	return default_flags
end

vim.keymap.set("n", "<leader>cx", function()
	vim.cmd("write")
	local ft = vim.bo.filetype
	local file = vim.fn.expand("%")
	local out = vim.fn.expand("%<")

	-- 1. C++ FILES
	if ft == "cpp" then
		-- Default fallback if no file exists
		local flags = get_compile_flags("-std=c++23")

		local cmd = string.format(
			"if clang++ %s '%s' -o '%s'; then ./'%s'; else echo '\n❌ Compilation Failed'; fi; echo ''; read -n 1 -s -r -p 'Press any key to close...'",
			flags,
			file,
			out,
			out
		)
		require("snacks").terminal(cmd, {
			win = {
				position = "bottom",
				height = 0.3,
				border = "rounded",
				title = " C++ Output ",
				title_pos = "center",
				style = "minimal",
			},
			interactive = true,
		})

	-- 2. C FILES
	elseif ft == "c" then
		-- Default fallback: Standard C17 + Math library
		local flags = get_compile_flags("-std=c17 -lm")

		local cmd = string.format(
			"if clang %s '%s' -o '%s'; then ./'%s'; else echo '\n❌ Compilation Failed'; fi; echo ''; read -n 1 -s -r -p 'Press any key to close...'",
			flags,
			file,
			out,
			out
		)
		require("snacks").terminal(cmd, {
			win = {
				position = "bottom",
				height = 0.3,
				border = "rounded",
				title = " C Output ",
				title_pos = "center",
				style = "minimal",
			},
			interactive = true,
		})

	-- 3. LUA
	elseif ft == "lua" then
		vim.cmd("source %")
	-- 4. PYTHON
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

-- ========================================================================== --
--  SEAMLESS BUILD & RUN SYSTEM
-- ========================================================================== --

local function build_and_run_project()
	vim.cmd("write")
	local build_cmd = ""
	local title = ""

	if vim.fn.filereadable("CMakeLists.txt") == 1 then
		-- 1. Build using CMake
		-- 2. Find the newest executable in build/ and run it
		build_cmd =
			"cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build"

		-- Shell magic: finds the newest file in build/ that has executable permissions
		local run_cmd =
			" && exe=$(find build -maxdepth 2 -type f -executable -not -path '*/.*' | xargs ls -t | head -n1); if [ -n \"$exe\" ]; then echo -e '\\n🚀 Running: '$exe'\\n'; ./\"$exe\"; else echo '\\n⚠️ No executable found in build/'; fi"

		build_cmd = build_cmd .. run_cmd
		title = " CMake Build & Run "
	elseif vim.fn.filereadable("Makefile") == 1 then
		-- Standard make assumes the binary is in the current directory or defined by target
		build_cmd =
			"make && echo -e '\\n🚀 Running Project...\\n' && ./$(ls -t | grep -v '\\.' | head -n1)"
		title = " Make Build & Run "
	else
		vim.notify("No build file found!", vim.log.levels.WARN)
		return
	end

	local final_cmd = string.format(
		"%s; echo ''; read -n 1 -s -r -p 'Process finished. Press any key to close...'",
		build_cmd
	)

	require("snacks").terminal(final_cmd, {
		win = {
			position = "bottom",
			height = 0.4,
			border = "rounded",
			title = title,
			title_pos = "center",
			style = "minimal",
		},
		interactive = true,
	})
end

-- Map it to <leader>cr ([C]ode [R]un Project)
-- Note: You might want to move your single-file runner to <leader>cx
-- and keep <leader>cr for project-level execution.
vim.keymap.set(
	"n",
	"<leader>cb",
	build_and_run_project,
	{ desc = "[C]ode [B]uild and Run Project" }
)
