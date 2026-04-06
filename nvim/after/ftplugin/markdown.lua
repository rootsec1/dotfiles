-- Neovim 0.12 starts Treesitter for markdown in the built-in ftplugin.
-- Keep markdown on the stable regex highlighter until the upstream crash is fixed.
vim.treesitter.stop()
vim.bo.syntax = "markdown"
