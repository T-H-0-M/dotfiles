-- TODO: Review could use more items from this
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	keys = {
		{ "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git status" },
		{ "<leader>gd", function() Snacks.picker.git_diff({ group = true }) end, desc = "Git diff" },
	},
	---@type snacks.Config
	opts = {
		-- refer to the configuration section below
		bigfile = {
			enabled = true,
			opt = {
				notify = true, -- show notification when big file detected
				size = 1.5 * 1024 * 1024, -- 1.5MB
				line_length = 1000, -- average line length (useful for minified files)
				-- Enable or disable features when big file detected
				---@param ctx {buf: number, ft:string}
				setup = function(ctx)
					if vim.fn.exists(":NoMatchParen") ~= 0 then
						vim.cmd([[NoMatchParen]])
					end
					Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
					vim.b.minianimate_disable = true
					vim.schedule(function()
						if vim.api.nvim_buf_is_valid(ctx.buf) then
							vim.bo[ctx.buf].syntax = ctx.ft
						end
					end)
				end,
			},
		},
		dashboard = { enabled = true },
		picker = { enabled = true },
		indent = {
			enabled = true,
			animate = {
				enabled = vim.fn.has("nvim-0.10") == 1,
				style = "out",
				easing = "linear",
				duration = {
					total = 100,
				},
			},
		},
		lazygit = { enabled = true },
		git = { enabled = true },
	},
}
