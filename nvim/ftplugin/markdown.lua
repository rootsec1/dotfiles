-- Neovim 0.12 can start markdown Treesitter too early and crash during redraw.
-- Mark the ftplugin as handled here so the built-in markdown ftplugin stays out.
if vim.b.did_ftplugin then
	return
end

vim.b.did_ftplugin = 1
vim.treesitter.stop()
vim.bo.syntax = "markdown"
