-- return {
-- 	"aktersnurra/no-clown-fiesta.nvim",
-- 	priority = 1000,
-- 	config = function()
-- 		require("no-clown-fiesta").setup({
-- 			transparent = true,
-- 			styles = {
-- 				comments = { italic = true },
-- 				functions = { bold = true },
-- 				keywords = { underline = true },
-- 				variables = {},
-- 				type = { bold = true },
-- 				lsp = { underline = true },
-- 				match_paren = { bold = true },
-- 			},
-- 		})
-- 		vim.cmd([[colorscheme no-clown-fiesta]])
-- 		local treesitter_groups = {
-- 			"@type.builtin", -- Built-in/primitive types
-- 			"@constant.builtin", -- Built-in constants like true/false
-- 		}
-- 		for _, group in ipairs(treesitter_groups) do
-- 			vim.api.nvim_set_hl(0, group, { bold = true })
-- 		end
-- 		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
-- 		vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
-- 		vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE" })
-- 		vim.api.nvim_set_hl(0, "PmenuSel", { bg = "NONE" })
-- 		vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "NONE" })
-- 		vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "NONE" })
-- 	end,
-- }

return {
	"KijitoraFinch/nanode.nvim",
	priority = 1000,
	config = function()
		require("nanode").setup({
			transparent = true,
		})
		vim.cmd.colorscheme("nanode")

		-- Make nvim-tree transparent
		vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "NvimTreeNormalFloat", { bg = "NONE" })
	end,
}
