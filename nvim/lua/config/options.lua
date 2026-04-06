local opt = vim.opt

opt.termguicolors = true
opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.mouse = "a"
opt.mousemodel = "extend"
opt.mousescroll = "ver:3,hor:6"
opt.mousefocus = true
opt.number = true
opt.relativenumber = false
opt.ruler = false
opt.cursorline = true
opt.cursorlineopt = "line"
opt.scrolloff = 6
opt.sidescrolloff = 8
opt.clipboard = "unnamedplus"
opt.fixendofline = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true
opt.splitbelow = true
opt.splitright = true
opt.signcolumn = "yes"
opt.laststatus = 3
opt.showtabline = 2
opt.showmode = false
opt.completeopt = { "menu", "menuone", "noselect" }
opt.confirm = true
opt.autoread = true
opt.undofile = true
opt.updatetime = 200
opt.timeoutlen = 500
opt.lazyredraw = true
opt.winborder = "rounded"
opt.splitkeep = "screen"
opt.foldenable = false
opt.foldlevel = 99
opt.pumheight = 10
opt.pumblend = 0
opt.fillchars = {
	eob = " ",
	fold = " ",
	diff = "╱",
	msgsep = " ",
	vert = "│",
}
opt.spell = false
opt.spelllang = { "en_us" }

if vim.g.neovide then
	vim.g.neovide_cursor_animation_length = 0
	vim.g.neovide_cursor_trail_size = 0
	vim.g.neovide_cursor_vfx_mode = ""
	vim.g.neovide_scroll_animation_length = 0.05
end

vim.diagnostic.config({
	virtual_text = {
		spacing = 2,
		source = "if_many",
		prefix = "●",
	},
	underline = true,
	signs = true,
	severity_sort = true,
	update_in_insert = false,
	float = {
		border = "rounded",
		source = "if_many",
	},
})
