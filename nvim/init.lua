vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = " "
vim.g.maplocalleader = " "

if vim.g.neovide then
	vim.o.guifont = "FiraCode Nerd Font Mono:h14"
	vim.g.neovide_input_use_logo = true
end

if vim.loader and vim.loader.enable then
	vim.loader.enable()
end

require("config.options")
require("config.ui")
require("config.bootstrap")
require("config.autocmds")
require("config.keymaps")
