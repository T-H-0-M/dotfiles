return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			dockerfile = { "hadolint" },
			go = { "golangci-lint" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		-- Safe lint function that handles missing linters
		local function safe_lint()
			local filetype = vim.bo.filetype
			local linters = lint.linters_by_ft[filetype]
			if not linters then
				return
			end

			-- Check if linters are available before trying to lint
			for _, linter_name in ipairs(linters) do
				local ok, _ = pcall(lint.get_linter, linter_name)
				if not ok then
					-- Linter not available, skip silently
					return
				end
			end

			lint.try_lint()
		end

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = safe_lint,
		})

		vim.keymap.set("n", "<leader>ll", safe_lint, { desc = "Trigger linting for current file" })
	end,
}
