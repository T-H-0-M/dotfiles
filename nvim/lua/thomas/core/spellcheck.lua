vim.opt.spell = false
vim.opt.spelllang = "en_au"

-- Enable spelling only for markdown files
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "mdx" },
	callback = function()
		vim.opt_local.spell = true
	end,
})
