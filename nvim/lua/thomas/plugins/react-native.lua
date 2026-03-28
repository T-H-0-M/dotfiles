return {
	{
		"windwp/nvim-ts-autotag",
		opts = {
			filetypes = {
				"html",
				"javascript",
				"typescript",
				"javascriptreact",
				"typescriptreact",
				"vue",
				"tsx",
				"jsx",
				"rescript",
				"xml",
				"php",
				"markdown",
				"astro",
				"glimmer",
				"handlebars",
				"hbs",
			},
		},
	},
	{
		"vuki656/package-info.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = {
			colors = {
				up_to_date = "#3C4048",
				outdated = "#d19a66",
			},
			icons = {
				enable = true,
				style = {
					up_to_date = "|  ",
					outdated = "|  ",
				},
			},
			autostart = true,
			hide_up_to_date = false,
			hide_unstable_versions = false,
		},
		event = { "BufRead package.json" },
	},
}

