return {
	"mrcjkb/rustaceanvim",
	version = "^6",
	lazy = false,
	ft = { "rust" },
	init = function()
		local ok, blink = pcall(require, "blink.cmp")
		local capabilities = ok and blink.get_lsp_capabilities()
			or vim.lsp.protocol.make_client_capabilities()

		vim.g.rustaceanvim = {
			tools = {
				float_win_config = { border = "rounded" },
			},
			server = {
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					if client.server_capabilities.inlayHintProvider then
						vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
					end
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false

					local map = function(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
					end
					map("<leader>rR", function() vim.cmd.RustLsp("runnables") end, "Rust runnables")
					map("<leader>rd", function() vim.cmd.RustLsp("debuggables") end, "Rust debuggables")
					map("<leader>rm", function() vim.cmd.RustLsp("expandMacro") end, "Rust expand macro")
					map("<leader>rp", function() vim.cmd.RustLsp("parentModule") end, "Rust parent module")
					map("<leader>re", function() vim.cmd.RustLsp("explainError") end, "Rust explain error")
					map("<leader>rH", function() vim.cmd.RustLsp({ "view", "hir" }) end, "Rust view HIR")
					map("<leader>rM", function() vim.cmd.RustLsp({ "view", "mir" }) end, "Rust view MIR")
					map("K", function() vim.cmd.RustLsp({ "hover", "actions" }) end, "Hover actions (Rust)")
				end,
				default_settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
							buildScripts = { enable = true },
						},
						checkOnSave = true,
						check = {
							command = "clippy",
							extraArgs = { "--no-deps" },
						},
						procMacro = {
							enable = true,
							ignored = {
								["async-trait"] = { "async_trait" },
								["napi-derive"] = { "async_trait" },
								["async-recursion"] = { "async_recursion" },
							},
						},
						inlayHints = {
							bindingModeHints = { enable = false },
							chainingHints = { enable = true },
							closingBraceHints = { enable = true, minLines = 25 },
							closureReturnTypeHints = { enable = "never" },
							lifetimeElisionHints = { enable = "skip_trivial", useParameterNames = false },
							parameterHints = { enable = true },
							reborrowHints = { enable = "never" },
							renderColons = true,
							typeHints = {
								enable = true,
								hideClosureInitialization = false,
								hideNamedConstructor = false,
							},
						},
						files = {
							excludeDirs = { ".direnv", ".git", "target", "node_modules" },
						},
					},
				},
			},
			dap = {},
		}
	end,
}
