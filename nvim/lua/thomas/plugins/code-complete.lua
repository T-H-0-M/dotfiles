return {
	"Exafunction/windsurf.vim",
	event = "BufEnter",
	config = function()
		vim.g.codeium_filetypes = {
			tex = false,
			markdown = false,
			mdx = false,
			go = false,
		}
	end,
}
