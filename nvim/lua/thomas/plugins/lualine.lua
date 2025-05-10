return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- Load the nanode theme and customize it
		local custom_theme = require("lualine.themes.nanode")

		-- Set black text for the b sections (blue background sections)
		-- This applies to all modes: normal, insert, visual, replace, command, inactive
		for _, mode in pairs(custom_theme) do
			if mode.a then
				mode.a.fg = "#000000"
			end
			if mode.z then
				mode.z.fg = "#000000"
			end
		end

		require("lualine").setup({
			options = {
				theme = custom_theme,
				icons_enabled = true,
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff" },
				lualine_c = { "filename" },
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
		})
	end,
}
