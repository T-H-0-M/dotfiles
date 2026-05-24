return {
	"tpope/vim-fugitive",
	cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Gedit", "GMove", "GRename", "GDelete", "GRemove" },
	keys = {
		{ "<leader>gg", "<cmd>Git<cr>", desc = "Git (fugitive status)" },
		{ "<leader>gD", "<cmd>Gdiffsplit<cr>", desc = "Git diff (current file)" },
	},
}
