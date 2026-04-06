local workspace = require("config.workspace")

local function map(mode, lhs, rhs, desc, opts)
	opts = opts or {}
	opts.desc = desc
	vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<C-p>", function()
	Snacks.picker.smart()
end, "Find files")

map("n", "<C-f>", function()
	Snacks.picker.lines()
end, "Search current file")

map("n", "<leader>f", function()
	Snacks.picker.grep()
end, "Search workspace")

map("n", "<leader>/", function()
	Snacks.picker.grep()
end, "Search workspace")

map("n", "<leader>s", function()
	Snacks.picker.pickers()
end, "Search everywhere")

map("n", "<leader><space>", function()
	Snacks.picker.pickers()
end, "Search everywhere")

map("n", "<leader>:", function()
	Snacks.picker.command_history()
end, "Command history")

map("n", "<leader>n", function()
	Snacks.notifier.show_history()
end, "Notification history")

map("n", "<leader>b", function()
	Snacks.picker.buffers()
end, "Switch buffer")

map("n", "<leader>p", function()
	Snacks.picker.commands()
end, "Command palette")

map("n", "<leader>h", function()
	Snacks.picker.recent()
end, "Recent files")

map("n", "<leader>o", function()
	Snacks.picker.lsp_workspace_symbols()
end, "Workspace symbols")

map("n", "<C-b>", function()
	workspace.toggle_tree()
end, "Toggle explorer")

map("n", "<leader>g", function()
	Snacks.lazygit()
end, "Open LazyGit")
map("n", "<leader>gs", function()
	Snacks.picker.git_status()
end, "Git status")
map("n", "<leader>gl", function()
	Snacks.picker.git_log()
end, "Git log")
map("n", "<leader>go", function()
	Snacks.gitbrowse.open({ what = "file" })
end, "Open in git browser")

map("n", "<C-s>", function()
	workspace.save_buffer(vim.api.nvim_get_current_buf())
end, "Save file")

map("i", "<C-s>", "<C-o><cmd>update<CR>", "Save file")

map("n", "<D-s>", function()
	workspace.save_buffer(vim.api.nvim_get_current_buf())
end, "Save file")
map("i", "<D-s>", "<C-o><cmd>update<CR>", "Save file")

map("n", "<C-a>", "ggVG", "Select all")
map("n", "<C-z>", "u", "Undo")
map("i", "<C-z>", "<C-o>u", "Undo")
map("v", "<C-z>", "<Esc>u", "Undo")
map("n", "<C-y>", "<C-r>", "Redo")
map("n", "<D-z>", "u", "Undo")
map("i", "<D-z>", "<C-o>u", "Undo")
map("v", "<D-z>", "<Esc>u", "Undo")
map("n", "<D-y>", "<C-r>", "Redo")
map("n", "<C-d>", "yyp", "Duplicate line")

map("n", "<leader>c", "gcc", "Toggle line comment", { remap = true })
map("v", "<leader>c", "gc", "Toggle comment", { remap = true })
map("n", "<C-_>", "gcc", "Toggle line comment", { remap = true })
map("n", "<C-/>", "gcc", "Toggle line comment", { remap = true })
map("v", "<C-_>", "gc", "Toggle comment", { remap = true })
map("v", "<C-/>", "gc", "Toggle comment", { remap = true })

map("n", "K", vim.lsp.buf.hover, "Hover details")
map("n", "gd", vim.lsp.buf.definition, "Go to definition")
map("n", "gr", vim.lsp.buf.references, "Find references")
map("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")
map("n", "<F12>", vim.lsp.buf.definition, "Go to definition")
map("n", "<S-F12>", function()
	Snacks.picker.lsp_references()
end, "Find references")

map("n", "<leader>.", vim.lsp.buf.code_action, "Code actions")
map("n", "<leader>e", vim.diagnostic.open_float, "Show diagnostics")
map("n", "<leader>r", vim.lsp.buf.rename, "Rename symbol")
map("n", "<leader>d", function()
	Snacks.picker.diagnostics()
end, "Workspace diagnostics")
map({ "n", "x" }, "<leader>sw", function()
	Snacks.picker.grep_word()
end, "Search word")

map("n", "<C-k>", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, "Format file")

map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", "Previous tab")
map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", "Next tab")
map("n", "<C-w>", workspace.close_current_buffer, "Close tab")
map("n", "<D-w>", workspace.close_current_buffer, "Close tab")

map("n", "<D-p>", function()
	Snacks.picker.smart()
end, "Find files")
map("n", "<D-f>", function()
	Snacks.picker.grep()
end, "Search workspace")
map("n", "<D-b>", function()
	workspace.toggle_tree()
end, "Toggle explorer")

map("n", "<C-h>", ":%s//gc<Left><Left><Left>", "Find and replace")
map("n", "<leader>q", "<cmd>qa<CR>", "Quit Neovim")
map("n", "<leader>?", function()
	require("which-key").show({ global = true })
end, "Show keymaps")
map("n", "<leader>sk", function()
	Snacks.picker.keymaps()
end, "Search keymaps")

map({ "n", "t" }, "]]", function()
	Snacks.words.jump(vim.v.count1)
end, "Next reference")
map({ "n", "t" }, "[[", function()
	Snacks.words.jump(-vim.v.count1)
end, "Previous reference")

map("n", "<C-c>", '"+yy', "Copy line")
map("n", "<C-x>", '"+dd', "Cut line")
map("n", "<C-v>", '"+p', "Paste")
map("v", "<C-c>", '"+y', "Copy selection")
map("v", "<C-x>", '"+d', "Cut selection")
map("i", "<C-v>", "<C-r>+", "Paste")

map({ "i", "v" }, "jj", "<Esc>", "Exit mode")
