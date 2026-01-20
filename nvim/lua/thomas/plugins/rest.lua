return {
	"rest-nvim/rest.nvim",
	ft = { "http" },
	cmd = { "Rest" },
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	init = function()
		---@type rest.Opts
		vim.g.rest_nvim = {
			-- Keep defaults; override here when needed.
		}
	end,
	keys = {
		{ "<leader>rr", "<cmd>Rest run<cr>", desc = "REST: Run request" },
		{ "<leader>rl", "<cmd>Rest last<cr>", desc = "REST: Run last request" },
		{ "<leader>ro", "<cmd>Rest open<cr>", desc = "REST: Open results" },
		{ "<leader>re", "<cmd>Rest env select<cr>", desc = "REST: Select env file" },
	},
	config = function()
		pcall(function()
			require("telescope").load_extension("rest")
		end)
	end,
}
