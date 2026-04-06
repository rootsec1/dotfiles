return {
	{
		"williamboman/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonLog" },
		build = ":MasonUpdate",
		opts = {
			ui = {
				border = "rounded",
			},
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = require("config.lsp").ensure_installed_servers(),
				automatic_installation = true,
			})
		end,
	},
	{
		"b0o/schemastore.nvim",
		lazy = true,
	},
	{
		"saghen/blink.cmp",
		version = "1.*",
		event = { "InsertEnter", "CmdlineEnter" },
		opts = {
			keymap = {
				preset = "super-tab",
				["<Tab>"] = {
					function(cmp)
						if cmp.snippet_active({ direction = 1 }) then
							return cmp.snippet_forward()
						end

						if cmp.is_visible() then
							return cmp.select_and_accept()
						end

						return cmp.show_and_insert_or_accept_single({ force = true })
					end,
					"fallback",
				},
			},
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
				list = {
					selection = {
						preselect = false,
						auto_insert = false,
					},
				},
				ghost_text = {
					enabled = false,
				},
			},
			signature = {
				enabled = false,
			},
			sources = {
				default = { "lsp", "path", "buffer" },
			},
			fuzzy = {
				implementation = "prefer_rust_with_warning",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"saghen/blink.cmp",
			"williamboman/mason-lspconfig.nvim",
			"b0o/schemastore.nvim",
		},
		config = function()
			require("config.lsp").setup()
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre", "BufNewFile" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "ruff_fix", "ruff_format" },
					javascript = { "prettier" },
					javascriptreact = { "prettier" },
					typescript = { "prettier" },
					typescriptreact = { "prettier" },
					json = { "prettier" },
					jsonc = { "prettier" },
					css = { "prettier" },
					html = { "prettier" },
					yaml = { "prettier" },
					markdown = { "prettier" },
					sh = { "shfmt" },
					bash = { "shfmt" },
					zsh = { "shfmt" },
				},
				format_on_save = {
					timeout_ms = 800,
					lsp_format = "fallback",
				},
			})

			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
}
