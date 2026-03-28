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

-- Lazy Git (via snacks.nvim)
keymap.set("n", "<leader>lg", function() Snacks.lazygit() end, { desc = "Lazy Git" })

-- Tmux Sessionizer
keymap.set("n", "<leader>fp", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Tmux Sessionizer" })

-- Picker (snacks.picker)
keymap.set("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find files in cwd" })
keymap.set("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Find recent files" })
keymap.set("n", "<leader>fs", function() Snacks.picker.grep() end, { desc = "Find string in cwd" })
keymap.set("n", "<leader>fc", function() Snacks.picker.grep_word() end, { desc = "Find string under cursor in cwd" })
keymap.set("n", "<leader>ft", function() Snacks.picker.todo_comments() end, { desc = "Find todos" })

-- nvim-tree
vim.keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" })
vim.keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
vim.keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })

vim.keymap.set("n", "<leader>gb", function()
	require("snacks").git.blame_line()
end, { desc = "Show git blame" })
