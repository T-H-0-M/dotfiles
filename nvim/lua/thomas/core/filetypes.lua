-- TODO: clean up this file

vim.filetype.add({
	extension = {
		mdx = "markdown",
		mdown = "markdown",
		mkd = "markdown",
		mkdn = "markdown",
		dockerfile = "dockerfile",
		Dockerfile = "dockerfile",
	},
	filename = {
		["Dockerfile"] = "dockerfile",
		["dockerfile"] = "dockerfile",
		[".dockerignore"] = "gitignore",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.breakindent = true
	end,
})

-- Use 2 space indents for TypeScript and React Native
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.expandtab = true
	end,
})

