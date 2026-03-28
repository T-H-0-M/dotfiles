return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		local treesitter = require("nvim-treesitter.configs")

		local parser_install = require("nvim-treesitter.install")
		parser_install.prefer_git = false

		treesitter.setup({ -- enable syntax highlighting
			highlight = {
				enable = true,
			},
			indent = { enable = true },
			ensure_installed = {
				"json",
				"javascript",
				"http",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"css",
				"prisma",
				"markdown",
				"markdown_inline",
				"bash",
				"lua",
				"vim",
				"dockerfile",
				"gitignore",
				"query",
				"vimdoc",
				"nix",
				"toml",
				"xml",
				"sql",
				"regex",
				"go",
				"gomod",
				"gosum",
				"gowork",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
		require("nvim-ts-autotag").setup()
	end,
}
