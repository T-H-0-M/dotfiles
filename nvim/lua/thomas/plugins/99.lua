return {
	"ThePrimeagen/99",
	dependencies = { "hrsh7th/nvim-cmp" },
	config = function()
		local _99 = require("99")
		local worker = _99.Extensions.Worker
		local default_model = "openai/gpt-5.3-codex"

		local function ensure_tmp_dir(tmp_file)
			local dir = vim.fn.fnamemodify(tmp_file, ":h")
			if dir and dir ~= "" then
				vim.fn.mkdir(dir, "p")
			end
		end

		local DevNullObserver = {
			on_stdout = function() end,
			on_stderr = function() end,
			on_complete = function() end,
		}

		local function once(fn)
			local called = false
			return function(...)
				if called then
					return
				end
				called = true
				fn(...)
			end
		end

		local OpenCodeHighProvider = {
			make_request = function(_, query, context, observer)
				local logger = context.logger:set_area("OpenCodeHighProvider")
				observer = observer or DevNullObserver
				if observer.on_start then
					observer.on_start()
				end

				ensure_tmp_dir(context.tmp_file)

				local once_complete = once(function(status, text)
					observer.on_complete(status, text)
				end)

				local command = {
					"opencode",
					"run",
					"--variant",
					"high",
					"-m",
					context.model or default_model,
					query,
				}

				local proc = vim.system(
					command,
					{
						text = true,
						stdout = vim.schedule_wrap(function(err, data)
							if context:is_cancelled() then
								once_complete("cancelled", "")
								return
							end
							if not err and data then
								observer.on_stdout(data)
							end
						end),
						stderr = vim.schedule_wrap(function(err, data)
							if context:is_cancelled() then
								once_complete("cancelled", "")
								return
							end
							if not err then
								observer.on_stderr(data)
							end
						end),
					},
					vim.schedule_wrap(function(obj)
						if context:is_cancelled() then
							once_complete("cancelled", "")
							return
						end
						if obj.code ~= 0 then
							local str = string.format(
								"process exit code: %d\n%s",
								obj.code,
								vim.inspect(obj)
							)
							once_complete("failed", str)
							logger:error("opencode run failed", "obj", obj)
							return
						end

						vim.schedule(function()
							local ok, res = pcall(function()
								return vim.fn.readfile(context.tmp_file)
							end)
							if not ok then
								once_complete("failed", "unable to retrieve response from llm")
								return
							end
							once_complete("success", table.concat(res, "\n"))
						end)
					end)
				)

				context:_set_process(proc)
			end,
		}

		-- For logging that is to a file if you wish to trace through requests
		-- for reporting bugs, i would not rely on this, but instead the provided
		-- logging mechanisms within 99.  This is for more debugging purposes
		local cwd = vim.uv.cwd()
		local basename = vim.fs.basename(cwd)
		_99.setup({
			logger = {
				level = _99.DEBUG,
				path = "/tmp/" .. basename .. ".99.debug",
				print_on_error = true,
			},
			provider = OpenCodeHighProvider,
			model = default_model,
			completion = {
				custom_rules = {
					"scratch/custom_rules/",
				},
				source = "cmp",
			},
			md_files = {
				"AGENT.md",
			},
		})

		vim.keymap.set("n", "<leader>ss", function()
			_99.search()
		end, { desc = "99 search" })

		vim.keymap.set("n", "<leader>vv", function()
			_99.search()
		end, { desc = "99 search prompt" })

		vim.keymap.set("n", "<leader>ww", function()
			worker.set_work()
		end, { desc = "99 set work" })

		vim.keymap.set("n", "<leader>9s", function()
			_99.search()
		end, { desc = "99 search" })

		vim.keymap.set("v", "<leader>9v", function()
			_99.visual()
		end, { desc = "99 visual prompt" })

		vim.keymap.set("n", "<leader>9x", function()
			_99.stop_all_requests()
		end, { desc = "99 stop requests" })
	end,
}
