return {
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
	},
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = {
			"NvimTreeOpen",
			"NvimTreeToggle",
			"NvimTreeFocus",
			"NvimTreeFindFile",
			"NvimTreeFindFileToggle",
		},
		config = function()
			local api = require("nvim-tree.api")

			local function tree_opts(bufnr, desc)
				return {
					buffer = bufnr,
					desc = "nvim-tree: " .. desc,
					noremap = true,
					nowait = true,
					silent = true,
				}
			end

			local function on_attach(bufnr)
				api.config.mappings.default_on_attach(bufnr)

				vim.keymap.set("n", "<LeftRelease>", function()
					api.node.open.edit()
				end, tree_opts(bufnr, "Open"))
				vim.keymap.set("n", "<2-LeftMouse>", function()
					api.node.open.edit()
				end, tree_opts(bufnr, "Open"))
				vim.keymap.set("n", "<MiddleMouse>", function()
					api.node.open.tab()
				end, tree_opts(bufnr, "Open in new tab"))
			end

			require("nvim-tree").setup({
				on_attach = on_attach,
				sync_root_with_cwd = true,
				respect_buf_cwd = true,
				hijack_cursor = true,
				hijack_netrw = true,
				update_focused_file = {
					enable = true,
					update_root = false,
				},
				hijack_directories = {
					enable = false,
					auto_open = false,
				},
				view = {
					width = 34,
					preserve_window_proportions = true,
					signcolumn = "no",
				},
				renderer = {
					root_folder_label = false,
					highlight_git = true,
					highlight_opened_files = "name",
					indent_markers = {
						enable = true,
					},
					icons = {
						show = {
							git = true,
							folder = true,
							file = true,
							folder_arrow = false,
						},
						glyphs = {
							folder = {
								arrow_closed = "▸",
								arrow_open = "▾",
								default = "󰉋",
								open = "󰝰",
								empty = "󰉖",
								empty_open = "󰷏",
							},
						},
					},
				},
				filters = {
					dotfiles = false,
				},
				actions = {
					open_file = {
						resize_window = false,
						window_picker = {
							enable = false,
						},
					},
				},
				git = {
					enable = true,
					ignore = false,
				},
				diagnostics = {
					enable = true,
					show_on_dirs = true,
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"bash",
					"css",
					"dockerfile",
					"gitignore",
					"html",
					"javascript",
					"json",
					"lua",
					"python",
					"toml",
					"typescript",
					"vim",
					"vimdoc",
					"yaml",
				},
				highlight = {
					enable = true,
					disable = { "markdown" },
					additional_vim_regex_highlighting = { "markdown" },
				},
				indent = { enable = true },
			})
		end,
	},
	{
		"nvim-mini/mini.nvim",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("mini.comment").setup()
			require("mini.pairs").setup()
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local colors = {
				normal = "#39ff14",
				insert = "#7dff72",
				visual = "#ff9d00",
				replace = "#ff5370",
				command = "#c586c0",
				fg = "#f0f0f0",
				bg = "#000000",
				panel = "#0d1319",
				active = "#000000",
			}

			local bubbles = {
				normal = {
					a = { fg = colors.bg, bg = colors.normal, gui = "bold" },
					b = { fg = colors.fg, bg = colors.panel },
					c = { fg = colors.fg, bg = colors.active },
				},
				insert = { a = { fg = colors.bg, bg = colors.insert, gui = "bold" } },
				visual = { a = { fg = colors.bg, bg = colors.visual, gui = "bold" } },
				replace = { a = { fg = colors.bg, bg = colors.replace, gui = "bold" } },
				command = { a = { fg = colors.bg, bg = colors.command, gui = "bold" } },
				inactive = {
					a = { fg = colors.fg, bg = colors.bg },
					b = { fg = colors.fg, bg = colors.bg },
					c = { fg = colors.fg, bg = colors.bg },
				},
			}

			require("lualine").setup({
				options = {
					theme = bubbles,
					globalstatus = true,
					component_separators = "",
					section_separators = { left = "", right = "" },
					disabled_filetypes = {
						statusline = { "NvimTree" },
					},
				},
				sections = {
					lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
					lualine_b = {
						{
							"filename",
							path = 1,
							symbols = {
								modified = " ●",
								readonly = " 󰌾",
								unnamed = "[No Name]",
							},
						},
						"branch",
					},
					lualine_c = {
						"diff",
						{
							"diagnostics",
							sources = { "nvim_diagnostic" },
							symbols = { error = "E ", warn = "W ", info = "I ", hint = "H " },
						},
					},
					lualine_x = {
						{
							function()
								local clients = vim.lsp.get_clients({ bufnr = 0 })
								if #clients == 0 then
									return ""
								end

								return table.concat(
									vim.tbl_map(function(client)
										return client.name
									end, clients),
									", "
								)
							end,
						},
					},
					lualine_y = { "filetype", "progress" },
					lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = { { "filename", path = 1 } },
					lualine_c = {},
					lualine_x = {},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		config = function()
			local workspace = require("config.workspace")

			require("bufferline").setup({
				options = {
					mode = "buffers",
					separator_style = "slant",
					diagnostics = "nvim_lsp",
					always_show_bufferline = true,
					show_close_icon = false,
					show_buffer_close_icons = true,
					left_mouse_command = function(bufnr)
						workspace.focus_buffer(bufnr)
					end,
					middle_mouse_command = function(bufnr)
						workspace.close_buffer(bufnr)
					end,
					close_command = function(bufnr)
						workspace.close_buffer(bufnr)
					end,
					right_mouse_command = function(bufnr)
						workspace.close_buffer(bufnr)
					end,
					offsets = {
						{
							filetype = "NvimTree",
							text = "Explorer",
							text_align = "left",
							separator = true,
						},
					},
					custom_filter = function(bufnr)
						if vim.startswith(vim.bo[bufnr].filetype, "snacks") then
							return false
						end

						if vim.bo[bufnr].filetype == "NvimTree" then
							return false
						end

						return workspace.is_real_file_buffer(bufnr)
					end,
				},
			})
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				current_line_blame = false,
				signcolumn = true,
			})
		end,
	},
}
