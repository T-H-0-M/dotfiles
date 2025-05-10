return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		telescope.setup({
			defaults = {
				file_ignore_patterns = { "node_modules", "venv", "%.png$", "%.jpg$", "%.jpeg$", "%.gif$", "%.bmp$" },
				path_display = { "smart" },
			},
		})
		telescope.load_extension("fzf")
	end,
}
