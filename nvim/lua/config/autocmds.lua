local augroup = vim.api.nvim_create_augroup("rootsec1_vscode_like", { clear = true })
local workspace = require("config.workspace")

local function refresh_if_file_changed()
	if vim.fn.mode() == "c" then
		return
	end

	workspace.refresh_changed_files()
end

vim.api.nvim_create_autocmd("TextChanged", {
	group = augroup,
	callback = function(args)
		workspace.schedule_autosave(args.buf, 900)
	end,
})

vim.api.nvim_create_autocmd("TextChangedI", {
	group = augroup,
	callback = function(args)
		workspace.schedule_autosave(args.buf, 900)
	end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost", "BufLeave" }, {
	group = augroup,
	callback = function(args)
		if args.buf and args.buf ~= 0 then
			workspace.stop_autosave(args.buf)
			workspace.save_buffer(args.buf)
			return
		end

		workspace.save_all_buffers()
	end,
})

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
	group = augroup,
	callback = function(args)
		workspace.stop_autosave(args.buf)
	end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinClosed", "TabEnter" }, {
	group = augroup,
	callback = function()
		vim.schedule(function()
			workspace.normalize_layout()
		end)
	end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	group = augroup,
	callback = refresh_if_file_changed,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup,
	callback = function(args)
		workspace.open_startup_layout(args)
	end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = augroup,
	callback = function()
		workspace.save_all_buffers()
	end,
})
