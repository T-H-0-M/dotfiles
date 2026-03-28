return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "antosha417/nvim-lsp-file-operations", config = true },
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		vim.diagnostic.config({
			virtual_text = {},
			float = {
				border = "rounded", -- Rounded borders for the floating windows (aesthetic)
				source = "always", -- Include the source of diagnostics in the display
				wrap = true, -- Crucial: enable text wrapping within floating windows
				max_width = 80, -- Set a max width to prevent messages from running off the screen
			},
			severity_sort = true, -- Sort messages by severity for better visibility
			underline = true, -- Continue to underline errors
			update_in_insert = false, -- Avoid updating diagnostics while typing
		})

		-- Create a custom highlight group for the hover window
		vim.cmd([[
		  highlight LspHoverWindow ctermbg=none guibg=#2e3440
		]])

		-- Configure the hover handler
		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			border = "rounded",
			max_width = 80,
			max_height = 20,
			focusable = false,
			style = "minimal",
			float = {
				border = "rounded",
				highlight = "LspHoverWindow",
				winblend = 0,
			},
		})
		-- import lspconfig plugin
		local lspconfig = require("lspconfig")

		local keymap = vim.keymap -- for conciseness

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", function() Snacks.picker.lsp_references() end, opts)

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, opts)

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", function() Snacks.picker.lsp_implementations() end, opts)

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", function() Snacks.picker.lsp_type_definitions() end, opts)

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", function() Snacks.picker.diagnostics_buffer() end, opts)

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		-- Configure diagnostic signs using modern vim.diagnostic.config (Neovim 0.11+)
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
		})

		-- Setup handlers after mason-lspconfig is loaded
		local mason_lspconfig = require("mason-lspconfig")

		-- Check if setup_handlers exists before calling it
		if mason_lspconfig.setup_handlers then
			mason_lspconfig.setup_handlers({
				-- default handler for installed servers
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
					})
				end,
			["emmet_ls"] = function()
				-- configure emmet language server
				lspconfig["emmet_ls"].setup({
					capabilities = capabilities,
					filetypes = {
						"html",
						"typescriptreact",
						"javascriptreact",
						"css",
						"sass",
						"scss",
						"less",
					},
				})
			end,
			["lua_ls"] = function()
					-- configure lua server (with special settings)
					lspconfig["lua_ls"].setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								-- make the language server recognize "vim" global
								diagnostics = {
									globals = { "vim" },
								},
								completion = {
									callSnippet = "Replace",
								},
							},
						},
					})
				end,
			-- ESLint is handled by nvim-lint with eslint_d for better performance
			-- No need for ESLint LSP server when using eslint_d through nvim-lint

			-- Configuration for Markdown (marksman)
				["marksman"] = function()
					lspconfig["marksman"].setup({
						capabilities = capabilities,
						filetypes = { "markdown", "mdx" }, -- Support for markdown and MDX files
					})
				end,

				-- Configuration for TypeScript (ts_ls) - Enhanced for React Native
				["ts_ls"] = function()
					lspconfig["ts_ls"].setup({
						capabilities = capabilities,
						filetypes = {
							"typescript",
							"typescriptreact",
							"javascript",
							"javascriptreact",
							"jsx",
							"tsx",
						},
						init_options = {
							preferences = {
								disableSuggestions = false,
								includeCompletionsForModuleExports = true,
								includeCompletionsForImportStatements = true,
							},
						},
						settings = {
							typescript = {
								inlayHints = {
									includeInlayParameterNameHints = "all",
									includeInlayParameterNameHintsWhenArgumentMatchesName = false,
									includeInlayFunctionParameterTypeHints = true,
									includeInlayVariableTypeHints = true,
									includeInlayPropertyDeclarationTypeHints = true,
									includeInlayFunctionLikeReturnTypeHints = true,
									includeInlayEnumMemberValueHints = true,
								},
								preferences = {
									importModuleSpecifier = "relative",
									includePackageJsonAutoImports = "auto",
									quotePreference = "double",
									jsxAttributeCompletionStyle = "auto",
								},
								suggest = {
									includeCompletionsForModuleExports = true,
									includeAutomaticOptionalChainCompletions = true,
								},
								format = {
									enable = false, -- Use conform.nvim instead
								},
							},
							javascript = {
								inlayHints = {
									includeInlayParameterNameHints = "all",
									includeInlayParameterNameHintsWhenArgumentMatchesName = false,
									includeInlayFunctionParameterTypeHints = true,
									includeInlayVariableTypeHints = true,
									includeInlayPropertyDeclarationTypeHints = true,
									includeInlayFunctionLikeReturnTypeHints = true,
									includeInlayEnumMemberValueHints = true,
								},
								preferences = {
									importModuleSpecifier = "relative",
									includePackageJsonAutoImports = "auto",
									quotePreference = "double",
								},
								suggest = {
									includeCompletionsForModuleExports = true,
									includeAutomaticOptionalChainCompletions = true,
								},
								format = {
									enable = false, -- Use conform.nvim instead
								},
							},
						},
						on_attach = function(client, bufnr)
							-- Disable formatting in favor of conform.nvim
							client.server_capabilities.documentFormattingProvider = false
							client.server_capabilities.documentRangeFormattingProvider = false

							-- Disable semantic tokens to use Tree-sitter highlighting
							client.server_capabilities.semanticTokensProvider = nil

							-- Enable inlay hints if supported
							if client.server_capabilities.inlayHintProvider then
								vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
							end
						end,
					})
				end,

				-- Configuration for JSON (jsonls)
				["jsonls"] = function()
					lspconfig["jsonls"].setup({
						capabilities = capabilities,
						filetypes = { "json", "jsonc" },
					})
				end,

				-- Configuration for Docker (dockerls)
				["dockerls"] = function()
					lspconfig["dockerls"].setup({
						capabilities = capabilities,
						filetypes = { "dockerfile" },
					})
				end,

				["pyright"] = function()
					local homebrew_python = "/opt/homebrew/bin/python3"
					local venv_path = vim.fn.getenv("VIRTUAL_ENV")

					if venv_path and type(venv_path) == "string" and venv_path ~= "" then
						-- Using virtual environment paths
						local site_packages_path = venv_path .. "/lib/python3.11/site-packages" -- specifically using Python 3.11
						lspconfig["pyright"].setup({
							capabilities = capabilities,
							settings = {
								python = {
									analysis = {
										autoSearchPaths = true,
										useLibraryCodeForTypes = true,
										extraPaths = { site_packages_path },
										typeCheckingMode = "basic",
									},
									pythonPath = venv_path .. "/bin/python", -- Using the virtual environment Python
								},
							},
							on_attach = function(client, bufnr)
								vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
								client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
							end,
						})
					else
						-- Using Homebrew Python as default if no VENV is found
						lspconfig["pyright"].setup({
							capabilities = capabilities,
							settings = {
								python = {
									analysis = {
										autoSearchPaths = true,
										useLibraryCodeForTypes = true,
										extraPaths = { "/opt/homebrew/lib/python3.11/site-packages" }, -- Corrected path for Python 3.11
										typeCheckingMode = "basic",
									},
									pythonPath = homebrew_python,
								},
							},
							on_attach = function(client, bufnr)
								vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
								client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
							end,
						})
					end
				end,

				-- Configuration for Go (gopls)
				["gopls"] = function()
					lspconfig["gopls"].setup({
						capabilities = capabilities,
						settings = {
							gopls = {
								gofumpt = true,
								codelenses = {
									gc_details = false,
									generate = true,
									regenerate_cgo = true,
									run_govulncheck = true,
									test = true,
									tidy = true,
									upgrade_dependency = true,
									vendor = true,
								},
								hints = {
									assignVariableTypes = true,
									compositeLiteralFields = true,
									compositeLiteralTypes = true,
									constantValues = true,
									functionTypeParameters = true,
									parameterNames = true,
									rangeVariableTypes = true,
								},
								analyses = {
									fieldalignment = true,
									nilness = true,
									unusedparams = true,
									unusedwrite = true,
									useany = true,
								},
								usePlaceholders = true,
								completeUnimported = true,
								staticcheck = true,
								directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
								semanticTokens = true,
							},
						},
						on_attach = function(client, bufnr)
							-- Enable inlay hints if supported
							if client.server_capabilities.inlayHintProvider then
								vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
							end
						end,
					})
				end,
			})
		end
	end,
}
