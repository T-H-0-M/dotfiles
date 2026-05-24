return {
	"rbong/vim-flog",
	cmd = { "Flog", "Flogsplit", "Floggit" },
	dependencies = { "tpope/vim-fugitive" },
	keys = {
		{ "<leader>gl", "<cmd>Flog<cr>", desc = "Git log graph (flog)" },
	},
}
