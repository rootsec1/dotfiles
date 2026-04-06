return {
	{
		"folke/snacks.nvim",
		priority = 900,
		lazy = false,
		opts = function()
			local function overlay_picker()
				return {
					hidden = { "preview" },
					layout = {
						backdrop = false,
						row = 0.3,
						width = 0.56,
						min_width = 90,
						max_width = 130,
						height = 0.42,
						box = "vertical",
						border = "rounded",
						title = " {title} {live} {flags} ",
						title_pos = "center",
						{ win = "input", height = 1, border = "bottom" },
						{ win = "list", border = "none" },
					},
					win = {
						input = {
							wo = {
								winblend = 0,
							},
						},
						list = {
							wo = {
								winblend = 0,
							},
						},
					},
				}
			end

			return {
				animate = { enabled = false },
				bigfile = {
					enabled = true,
					notify = false,
				},
				dashboard = { enabled = false },
				explorer = {
					enabled = false,
					replace_netrw = false,
				},
				gitbrowse = {
					enabled = true,
					notify = false,
				},
				input = { enabled = true },
				lazygit = {
					enabled = true,
					configure = true,
				},
				notifier = {
					enabled = true,
					timeout = 2500,
					style = "compact",
				},
				picker = {
					enabled = true,
					ui_select = true,
					sources = {
						smart = {
							hidden = true,
							ignored = false,
							layout = overlay_picker(),
						},
						grep = {
							hidden = true,
							ignored = false,
							layout = overlay_picker(),
						},
						buffers = {
							layout = overlay_picker(),
						},
						command_history = {
							layout = overlay_picker(),
						},
						commands = {
							layout = overlay_picker(),
						},
						diagnostics = {
							layout = overlay_picker(),
						},
						git_log = {
							layout = overlay_picker(),
						},
						git_status = {
							layout = overlay_picker(),
						},
						keymaps = {
							layout = overlay_picker(),
						},
						lines = {
							layout = overlay_picker(),
						},
						lsp_references = {
							layout = overlay_picker(),
						},
						lsp_workspace_symbols = {
							layout = overlay_picker(),
						},
						pickers = {
							layout = overlay_picker(),
						},
						recent = {
							layout = overlay_picker(),
						},
					},
				},
				quickfile = { enabled = false },
				statuscolumn = { enabled = true },
				terminal = { enabled = false },
				words = {
					enabled = true,
					debounce = 150,
					notify_end = false,
					modes = { "n" },
				},
				styles = {
					input = {
						border = "rounded",
						backdrop = false,
						row = 0.28,
						width = 0.46,
						title_pos = "center",
						wo = {
							winblend = 0,
						},
					},
					lazygit = {
						border = "rounded",
						backdrop = false,
						width = 0.94,
						height = 0.9,
						row = 0.04,
						col = 0.03,
					},
					notification = {
						border = "rounded",
						backdrop = false,
						wo = {
							wrap = true,
						},
					},
					notification_history = {
						border = "rounded",
						backdrop = false,
						width = 0.7,
						height = 0.55,
						row = 0.2,
						col = 0.15,
						wo = {
							wrap = true,
						},
					},
				},
			}
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
			delay = function(ctx)
				return ctx.plugin and 0 or 150
			end,
			win = {
				border = "rounded",
				title = true,
				title_pos = "center",
			},
			layout = {
				width = {
					min = 20,
					max = 40,
				},
				spacing = 4,
			},
		},
	},
}
