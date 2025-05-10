vim.cmd([[set spell]])
vim.cmd([[set spelllang=en_au]])

-- INFO: Only enable spelling in LaTeX files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "tex",
	command = "setlocal spell",
})
