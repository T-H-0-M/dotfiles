return {
	"esmuellert/codediff.nvim",
	cmd = "CodeDiff",
	opts = {
		keymaps = {
			view = {
				close_on_open_in_prev_tab = true,
			},
		},
	},
	keys = {
		{
			"<leader>ld",
			function()
				local lifecycle = require("codediff.ui.lifecycle")

				local codediff_tabs = {}
				for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
					if lifecycle.get_session(tab) ~= nil then
						table.insert(codediff_tabs, tab)
					end
				end

				if #codediff_tabs > 0 then
					local current_tab = vim.api.nvim_get_current_tabpage()
					if lifecycle.get_session(current_tab) ~= nil then
						local fallback_tab = nil
						for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
							if lifecycle.get_session(tab) == nil then
								fallback_tab = tab
								break
							end
						end

						if fallback_tab then
							vim.api.nvim_set_current_tabpage(fallback_tab)
						else
							vim.cmd("tabnew")
						end
					end

					table.sort(codediff_tabs, function(a, b)
						return vim.api.nvim_tabpage_get_number(a) > vim.api.nvim_tabpage_get_number(b)
					end)

					for _, tab in ipairs(codediff_tabs) do
						if vim.api.nvim_tabpage_is_valid(tab) then
							local tab_number = vim.api.nvim_tabpage_get_number(tab)
							pcall(vim.cmd, tab_number .. "tabclose")
						end
					end

					return
				end

				vim.cmd("CodeDiff")
			end,
			desc = "CodeDiff (toggle)",
		},
	},
}
