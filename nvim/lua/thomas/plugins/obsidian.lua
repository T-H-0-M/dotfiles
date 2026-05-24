return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		workspaces = {
			{ name = "personal", path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Personal" },
		},
		ui = { enable = false },
		legacy_commands = false,
		templates = {
			folder = "_templates",
		},
		daily_notes = {
			folder = "Daily Notes",
			template = "daily.md",
		},
	},
	keys = {
		{ "<leader>on", "<cmd>Obsidian new<cr>", desc = "New note" },
		{ "<leader>oo", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian" },
		{ "<leader>of", "<cmd>Obsidian quick_switch<cr>", desc = "Find note" },
		{ "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search notes" },
		{ "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
		{ "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Links" },
		{ "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Today" },
		{ "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Yesterday" },
		{ "<leader>ott", "<cmd>Obsidian tomorrow<cr>", desc = "Tomorrow" },
	},
}
