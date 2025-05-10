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

