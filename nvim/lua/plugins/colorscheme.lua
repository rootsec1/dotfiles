return {
	{
		"navarasu/onedark.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "dark",
			transparent = true,
			term_colors = true,
			code_style = {
				comments = "none",
				keywords = "none",
				functions = "none",
				strings = "none",
				variables = "none",
			},
			diagnostics = {
				darker = true,
				undercurl = true,
				background = false,
			},
			colors = {
				bg0 = "#000000",
				bg1 = "#060a0f",
				bg2 = "#0d1319",
				bg3 = "#101820",
				bg_d = "#000000",
				bg_blue = "#0f2a12",
				bg_yellow = "#402300",
				fg = "#ffffff",
				purple = "#c586c0",
				green = "#6a9955",
				orange = "#ce9178",
				blue = "#39ff14",
				yellow = "#dcdcaa",
				cyan = "#39ff14",
				red = "#f48771",
				grey = "#6a737d",
				light_grey = "#eef6ee",
			},
		},
		config = function(_, opts)
			require("onedark").setup(opts)
			require("onedark").load()
		end,
	},
}
