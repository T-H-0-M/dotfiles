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
		vim.api.nvim_create_autocmd("User", {
			pattern = "RestResponsePre",
			callback = function()
				if vim.fn.executable("jq") ~= 1 then
					return
				end

				local res = rawget(_G, "rest_response")
				if type(res) ~= "table" then
					return
				end

				local body = res.body
				if type(body) ~= "string" or body == "" then
					return
				end
				if #body > 2000000 then
					return
				end

				local trimmed = vim.trim(body)
				local first = trimmed:sub(1, 1)
				if first ~= "{" and first ~= "[" then
					return
				end

				local formatted = vim.fn.system({ "jq", "." }, body)
				if vim.v.shell_error == 0 and type(formatted) == "string" and formatted ~= "" then
					res.body = formatted
				end
			end,
		})

	end,
}
