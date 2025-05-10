return {
	"lervag/vimtex",
	lazy = false, -- Don't lazy load VimTeX
	ft = "tex", -- Load for TeX files
	init = function()
		-- PDF viewer configuration (adjust based on your system)
		-- Common options: "zathura" (Linux/macOS), "okular" (Linux), "skim" (macOS), "sumatrapdf" (Windows)
		vim.g.vimtex_view_method = "skim" -- Use general viewer

		-- Compiler configuration
		vim.g.vimtex_compiler_method = "latexmk"
		vim.g.vimtex_compiler_latexmk = {
			continuous = 0, -- Disable continuous compilation
			options = {
				"-verbose",
				"-file-line-error",
				"-synctex=1",
				"-interaction=nonstopmode",
			},
		}

		-- Completion settings
		vim.g.vimtex_complete_enabled = 1
		vim.g.vimtex_complete_close_braces = 1

		-- Disable quickfix auto open (can be annoying)
		vim.g.vimtex_quickfix_mode = 0

		-- Ignore certain common LaTeX warnings
		vim.g.vimtex_quickfix_ignore_filters = {
			"Underfull \\\\hbox",
			"Overfull \\\\hbox",
			"LaTeX Warning: .*float specifier changed to",
			"LaTeX hooks Warning",
		}

		-- Configure folding
		vim.g.vimtex_fold_enabled = 1
		vim.g.vimtex_fold_manual = 0

		-- Enable concealment for a cleaner view (optional)
		vim.g.vimtex_syntax_conceal = {
			accents = 1,
			ligatures = 1,
			cites = 1,
			fancy = 1,
			spacing = 1,
			greek = 1,
			math_bounds = 1,
			math_delimiters = 1,
			math_fracs = 1,
			math_super_sub = 1,
			math_symbols = 1,
			sections = 0,
			styles = 1,
		}

		-- Configure table of contents
		vim.g.vimtex_toc_config = {
			name = "TOC",
			layers = { "content", "todo", "include" },
			split_width = 25,
			todo_sorted = 0,
			show_help = 1,
			show_numbers = 1,
		}
	end,
}
