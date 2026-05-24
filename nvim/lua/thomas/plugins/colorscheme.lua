return {
	"ellisonleao/gruvbox.nvim",
	priority = 1000,
	opts = {
		contrast = "hard",
		transparent_mode = true,
		overrides = {
			NormalFloat = { bg = "NONE" },
			FloatBorder = { bg = "NONE" },
			Pmenu = { bg = "NONE" },
			PmenuSel = { bg = "NONE" },
			PmenuSbar = { bg = "NONE" },
			PmenuThumb = { bg = "NONE" },
		},
	},
	config = function(_, opts)
		vim.o.background = "dark"
		require("gruvbox").setup(opts)
		vim.cmd.colorscheme("gruvbox")

		local treesitter_groups = {
			"@type.builtin",
			"@constant.builtin",
		}

		for _, group in ipairs(treesitter_groups) do
			vim.api.nvim_set_hl(0, group, { bold = true })
		end
	end,
}
