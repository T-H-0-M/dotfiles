return {
	"Exafunction/windsurf.vim",
	event = "BufEnter",
	config = function()
		vim.g.codeium_filetypes = {
			tex = false,
			markdown = false,
			mdx = false,
		}

		-- Toggle Windsurf AI completions
		vim.keymap.set("n", "<leader>ai", "<cmd>CodeiumToggle<cr>", { desc = "Toggle Windsurf AI completions" })
	end,
}
