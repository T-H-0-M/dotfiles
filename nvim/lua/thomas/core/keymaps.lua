vim.g.mapleader = " "
local keymap = vim.keymap

---------------------
-- General Keymaps
---------------------

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

---------------------
-- Window Keymaps
---------------------
keymap.set("n", "<leader>n1", "<cmd>1wincmd w<CR>", { desc = "Jump to the 1st window" })
keymap.set("n", "<leader>n2", "<cmd>2wincmd w<CR>", { desc = "Jump to the 2nd window" })
keymap.set("n", "<leader>n3", "<cmd>3wincmd w<CR>", { desc = "Jump to the 3rd window" })
keymap.set("n", "<leader>n4", "<cmd>4wincmd w<CR>", { desc = "Jump to the 4th window" })

keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window
keymap.set("n", "<Leader>nw", "<C-w>w", { noremap = true, silent = true }) -- switch to next window
keymap.set("n", "<Leader>pw", "<C-w>W", { noremap = true, silent = true }) -- switch to previous window

-- Tmux Sessionizer
keymap.set("n", "<leader>fp", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Tmux Sessionizer" })

-- Picker (snacks.picker)
keymap.set("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find files in cwd" })
keymap.set("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Find recent files" })
keymap.set("n", "<leader>fs", function() Snacks.picker.grep() end, { desc = "Find string in cwd" })
keymap.set("n", "<leader>fc", function() Snacks.picker.grep_word() end, { desc = "Find string under cursor in cwd" })
keymap.set("n", "<leader>ft", function() Snacks.picker.todo_comments() end, { desc = "Find todos" })

-- Explorer (snacks.explorer)
local function get_explorer_picker()
	return Snacks.picker.get({ source = "explorer" })[1]
end

keymap.set("n", "<leader>ee", function()
	local explorer = get_explorer_picker()
	if explorer then
		explorer:close()
	else
		Snacks.explorer({ jump = { close = true } })
	end
end, { desc = "Toggle file explorer" })

keymap.set("n", "<leader>ef", function()
	local explorer = get_explorer_picker()
	if explorer then
		explorer:close()
	else
		Snacks.explorer({ follow_file = true, jump = { close = true } })
	end
end, { desc = "Toggle file explorer on current file" })

keymap.set("n", "<leader>ec", function()
	local explorer = get_explorer_picker()
	if explorer then
		explorer:action("explorer_close_all")
	end
end, { desc = "Collapse file explorer" })

keymap.set("n", "<leader>er", function()
	local explorer = get_explorer_picker()
	if explorer then
		explorer:action("explorer_update")
	else
		Snacks.explorer({ jump = { close = true } })
	end
end, { desc = "Refresh file explorer" })

vim.keymap.set("n", "<leader>gb", function()
	require("snacks").git.blame_line()
end, { desc = "Show git blame" })
