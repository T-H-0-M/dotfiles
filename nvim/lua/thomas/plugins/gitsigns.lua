return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signcolumn = true,
		numhl = false,
		linehl = false,
		word_diff = false,
		current_line_blame = false,
		signs = {
			add = { text = "│" },
			change = { text = "│" },
			delete = { text = "▁" },
			topdelete = { text = "▔" },
			changedelete = { text = "│" },
			untracked = { text = "┆" },
		},
		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")

			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
			end

			map("n", "]h", function()
				gitsigns.nav_hunk("next")
			end, "Next hunk")
			map("n", "[h", function()
				gitsigns.nav_hunk("prev")
			end, "Previous hunk")
			map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk")
			map("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
		end,
	},
}
