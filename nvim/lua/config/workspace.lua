local M = {}
local uv = vim.uv or vim.loop

local autosave_timers = {}
local tree_width = 34
local is_directory_buffer
local excluded_real_filetypes = {
	checkhealth = true,
}

local function valid_buffer(bufnr)
	return bufnr and bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr)
end

local function valid_window(winid)
	return winid and winid > 0 and vim.api.nvim_win_is_valid(winid)
end

local function buffer_name(bufnr)
	if not valid_buffer(bufnr) then
		return ""
	end

	return vim.api.nvim_buf_get_name(bufnr)
end

local function is_snacks_buffer(bufnr)
	if not valid_buffer(bufnr) then
		return false
	end

	return vim.startswith(vim.bo[bufnr].filetype, "snacks")
end

local function is_tree_buffer(bufnr)
	return valid_buffer(bufnr) and vim.bo[bufnr].filetype == "NvimTree"
end

local function is_placeholder_buffer(bufnr)
	return valid_buffer(bufnr) and vim.b[bufnr].workspace_placeholder == true
end

local function is_editor_buffer(bufnr)
	if not valid_buffer(bufnr) then
		return false
	end

	if vim.bo[bufnr].buftype ~= "" then
		return false
	end

	return not is_snacks_buffer(bufnr) and not is_tree_buffer(bufnr) and not is_directory_buffer(bufnr)
end

is_directory_buffer = function(bufnr)
	local name = buffer_name(bufnr)
	return name ~= "" and vim.fn.isdirectory(name) == 1
end

local function create_placeholder_buffer()
	local bufnr = vim.api.nvim_create_buf(false, false)
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].buflisted = false
	vim.bo[bufnr].swapfile = false
	vim.b[bufnr].workspace_placeholder = true
	return bufnr
end

local function set_placeholder_buffer(winid)
	local bufnr = create_placeholder_buffer()
	vim.api.nvim_win_set_buf(winid, bufnr)
	return bufnr
end

local function listed_file_buffers()
	local buffers = {}

	for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
		local bufnr = info.bufnr
		if M.is_real_file_buffer(bufnr) then
			table.insert(buffers, bufnr)
		end
	end

	return buffers
end

local function next_file_buffer(current)
	local buffers = listed_file_buffers()
	if #buffers == 0 then
		return nil
	end

	for index, bufnr in ipairs(buffers) do
		if bufnr == current then
			return buffers[index + 1] or buffers[index - 1]
		end
	end

	return buffers[1]
end

local function window_showing_buffer(bufnr)
	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_config(winid).relative == "" and vim.api.nvim_win_get_buf(winid) == bufnr then
			return winid
		end
	end
end

local function tree_win()
	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_config(winid).relative == "" and is_tree_buffer(vim.api.nvim_win_get_buf(winid)) then
			return winid
		end
	end
end

local function wants_tree()
	return vim.t.workspace_tree_enabled ~= false
end

local function set_tree_enabled(enabled)
	vim.t.workspace_tree_enabled = enabled
end

local function editor_windows()
	local windows = {}

	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_config(winid).relative == "" then
			local bufnr = vim.api.nvim_win_get_buf(winid)
			if is_editor_buffer(bufnr) then
				table.insert(windows, {
					winid = winid,
					bufnr = bufnr,
					real = M.is_real_file_buffer(bufnr),
					placeholder = is_placeholder_buffer(bufnr),
				})
			end
		end
	end

	return windows
end

local function find_editor_window()
	local fallback

	for _, window in ipairs(editor_windows()) do
		if window.real then
			return window.winid, window.bufnr
		end

		fallback = fallback or window
	end

	if fallback then
		return fallback.winid, fallback.bufnr
	end
end

local function focus_tree()
	local api = require("nvim-tree.api")
	if api.tree.is_visible() then
		api.tree.focus()
	end
	return tree_win()
end

local function open_tree()
	local api = require("nvim-tree.api")
	if not api.tree.is_visible() then
		api.tree.open()
	end
	return tree_win()
end

local function close_tree()
	local api = require("nvim-tree.api")
	if api.tree.is_visible() then
		api.tree.close()
	end
end

local function normalize_tree_window()
	local winid = tree_win()
	if not valid_window(winid) then
		return nil
	end

	vim.wo[winid].winfixwidth = true
	pcall(vim.api.nvim_win_set_width, winid, tree_width)
	return winid
end

local function close_window_if_possible(winid)
	if not valid_window(winid) then
		return
	end

	if #vim.api.nvim_tabpage_list_wins(0) <= 1 then
		return
	end

	pcall(vim.api.nvim_win_close, winid, true)
end

local function cleanup_editor_artifacts()
	local windows = editor_windows()
	if #windows <= 1 then
		return
	end

	local current_win = vim.api.nvim_get_current_win()
	local has_real = false
	local keep

	for _, window in ipairs(windows) do
		has_real = has_real or window.real
		if window.winid == current_win then
			keep = window
		end
	end

	if has_real then
		for _, window in ipairs(windows) do
			if window.placeholder then
				close_window_if_possible(window.winid)
			end
		end
		return
	end

	if not keep or not keep.placeholder then
		for _, window in ipairs(windows) do
			if window.placeholder then
				keep = window
				break
			end
		end
	end

	keep = keep or windows[1]

	for _, window in ipairs(windows) do
		if window.winid ~= keep.winid then
			close_window_if_possible(window.winid)
		end
	end

	if valid_window(keep.winid) and not is_placeholder_buffer(vim.api.nvim_win_get_buf(keep.winid)) then
		set_placeholder_buffer(keep.winid)
	end
end

local function cleanup_directory_artifacts()
	for _, tabid in ipairs(vim.api.nvim_list_tabpages()) do
		for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabid)) do
			local bufnr = vim.api.nvim_win_get_buf(winid)
			if is_directory_buffer(bufnr) then
				set_placeholder_buffer(winid)
				pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
			end
		end
	end

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if valid_buffer(bufnr) and is_directory_buffer(bufnr) and #vim.fn.win_findbuf(bufnr) == 0 then
			pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
		end
	end
end

local function normalize_editor_windows()
	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_config(winid).relative == "" then
			local bufnr = vim.api.nvim_win_get_buf(winid)
			if is_editor_buffer(bufnr) then
				vim.wo[winid].winfixwidth = false
			end
		end
	end
end

function M.normalize_layout()
	local tree = tree_win()

	if wants_tree() and not valid_window(tree) then
		open_tree()
		tree = tree_win()
	elseif not wants_tree() and valid_window(tree) then
		close_tree()
		tree = nil
	end

	cleanup_directory_artifacts()
	cleanup_editor_artifacts()
	tree = normalize_tree_window()
	local editor_win = find_editor_window()

	if not editor_win then
		if valid_window(tree) then
			vim.api.nvim_set_current_win(tree)
			vim.cmd("rightbelow vsplit")
		else
			vim.cmd("vnew")
		end

		set_placeholder_buffer(vim.api.nvim_get_current_win())
	end

	cleanup_editor_artifacts()
	normalize_tree_window()
	normalize_editor_windows()
end

function M.is_real_file_buffer(bufnr)
	if not is_editor_buffer(bufnr) then
		return false
	end

	if not vim.bo[bufnr].buflisted or not vim.bo[bufnr].modifiable or vim.bo[bufnr].readonly then
		return false
	end

	if excluded_real_filetypes[vim.bo[bufnr].filetype] then
		return false
	end

	return buffer_name(bufnr) ~= ""
end

function M.stop_autosave(bufnr)
	local timer = autosave_timers[bufnr]
	if not timer then
		return
	end

	timer:stop()
	timer:close()
	autosave_timers[bufnr] = nil
end

function M.save_buffer(bufnr)
	if not M.is_real_file_buffer(bufnr) or not vim.bo[bufnr].modified then
		return
	end

	pcall(vim.api.nvim_buf_call, bufnr, function()
		vim.cmd("silent update")
	end)
end

function M.save_all_buffers()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		M.stop_autosave(bufnr)
		M.save_buffer(bufnr)
	end
end

function M.refresh_changed_files()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if M.is_real_file_buffer(bufnr) and not vim.bo[bufnr].modified then
			vim.api.nvim_buf_call(bufnr, function()
				pcall(vim.cmd, "checktime")
			end)
		end
	end
end

function M.schedule_autosave(bufnr, delay_ms)
	if not M.is_real_file_buffer(bufnr) then
		return
	end

	M.stop_autosave(bufnr)

	local timer = uv.new_timer()
	autosave_timers[bufnr] = timer

	timer:start(
		delay_ms,
		0,
		vim.schedule_wrap(function()
			M.stop_autosave(bufnr)
			M.save_buffer(bufnr)
		end)
	)
end

function M.focus_editor_window(preferred)
	if valid_window(preferred) then
		local bufnr = vim.api.nvim_win_get_buf(preferred)
		if is_editor_buffer(bufnr) then
			vim.api.nvim_set_current_win(preferred)
			return preferred, bufnr
		end
	end

	local winid, bufnr = find_editor_window()
	if winid then
		vim.api.nvim_set_current_win(winid)
		return winid, bufnr
	end
end

function M.ensure_blank_editor()
	local winid, bufnr = M.focus_editor_window(vim.api.nvim_get_current_win())
	if winid and bufnr then
		local name = buffer_name(bufnr)
		if name == "" and not vim.bo[bufnr].modified and vim.bo[bufnr].filetype == "" then
			return winid, bufnr
		end
	end

	if winid then
		bufnr = set_placeholder_buffer(winid)
		return winid, bufnr
	end

	vim.cmd("vnew")
	bufnr = set_placeholder_buffer(vim.api.nvim_get_current_win())
	return vim.api.nvim_get_current_win(), bufnr
end

function M.ensure_editor_window()
	local winid, bufnr = find_editor_window()
	if winid then
		vim.api.nvim_set_current_win(winid)
		return winid, bufnr
	end

	M.normalize_layout()
	return M.focus_editor_window(vim.api.nvim_get_current_win())
end

function M.focus_buffer(bufnr)
	if not M.is_real_file_buffer(bufnr) then
		return
	end

	local target_win = window_showing_buffer(bufnr)
	if valid_window(target_win) and not is_tree_buffer(vim.api.nvim_win_get_buf(target_win)) then
		vim.api.nvim_set_current_win(target_win)
		return target_win, bufnr
	end

	local editor_win = M.ensure_editor_window()
	if editor_win then
		vim.api.nvim_win_set_buf(editor_win, bufnr)
		vim.api.nvim_set_current_win(editor_win)
		return editor_win, bufnr
	end
end

function M.close_current_buffer()
	local current_buf = vim.api.nvim_get_current_buf()

	if is_tree_buffer(current_buf) then
		local _, editor_buf = find_editor_window()
		if not editor_buf then
			M.ensure_blank_editor()
			vim.schedule(M.normalize_layout)
			return
		end
		current_buf = editor_buf
	end

	M.close_buffer(current_buf)
end

function M.close_buffer(bufnr)
	if not valid_buffer(bufnr) then
		return
	end

	local restore_win = vim.api.nvim_get_current_win()
	local target_win = window_showing_buffer(bufnr)

	if is_tree_buffer(bufnr) then
		set_tree_enabled(false)
		close_tree()
		vim.schedule(function()
			M.normalize_layout()
			if valid_window(restore_win) then
				vim.api.nvim_set_current_win(restore_win)
			else
				M.focus_editor_window()
			end
		end)
		return
	end

	if vim.bo[bufnr].buftype ~= "" or is_snacks_buffer(bufnr) then
		if valid_window(target_win) then
			pcall(vim.api.nvim_win_close, target_win, true)
		elseif vim.api.nvim_get_current_buf() == bufnr then
			pcall(vim.cmd, "close")
		end

		vim.schedule(function()
			M.normalize_layout()
			if valid_window(restore_win) then
				vim.api.nvim_set_current_win(restore_win)
			else
				M.focus_editor_window()
			end
		end)
		return
	end

	if not M.is_real_file_buffer(bufnr) then
		if valid_window(target_win) then
			set_placeholder_buffer(target_win)
		end
		pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
		vim.schedule(function()
			M.normalize_layout()
			if valid_window(restore_win) then
				vim.api.nvim_set_current_win(restore_win)
			else
				M.focus_editor_window()
			end
		end)
		return
	end

	local replacement = next_file_buffer(bufnr)
	if replacement == bufnr then
		replacement = nil
	end

	if valid_window(target_win) then
		if replacement then
			vim.api.nvim_win_set_buf(target_win, replacement)
		else
			set_placeholder_buffer(target_win)
		end
	end

	M.save_buffer(bufnr)

	local ok = pcall(vim.api.nvim_buf_delete, bufnr, {})
	if not ok and valid_window(target_win) and valid_buffer(bufnr) then
		vim.api.nvim_win_set_buf(target_win, bufnr)
	end

	vim.schedule(function()
		M.normalize_layout()
		if valid_window(restore_win) then
			vim.api.nvim_set_current_win(restore_win)
		else
			M.focus_editor_window()
		end
	end)
end

function M.reveal_buffer(bufnr)
	if not M.is_real_file_buffer(bufnr) then
		return
	end

	pcall(vim.cmd, "NvimTreeFindFile!")
end

local function cleanup_directory_buffer(bufnr)
	if not valid_buffer(bufnr) or not is_directory_buffer(bufnr) then
		return
	end

	pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
end

local function finalize_layout(editor_win, cb)
	vim.defer_fn(function()
		if cb then
			cb()
		end
		M.normalize_layout()
		M.focus_editor_window(editor_win)
	end, 30)
end

function M.open_startup_layout(data)
	local path = data.file ~= "" and vim.fn.fnamemodify(data.file, ":p") or ""
	local editor_win = vim.api.nvim_get_current_win()
	set_tree_enabled(true)

	if path ~= "" and vim.fn.isdirectory(path) == 1 then
		vim.cmd.cd(vim.fn.fnameescape(path))
		M.ensure_blank_editor()
		cleanup_directory_buffer(data.buf)

		vim.schedule(function()
			open_tree()
			finalize_layout(editor_win)
		end)

		return
	end

	if path == "" then
		M.ensure_blank_editor()
	end

	vim.schedule(function()
		open_tree()

		finalize_layout(editor_win, function()
			if path ~= "" and valid_buffer(data.buf) then
				M.reveal_buffer(data.buf)
			end
		end)
	end)
end

function M.toggle_tree()
	local api = require("nvim-tree.api")
	if api.tree.is_visible() then
		local current = vim.api.nvim_get_current_buf()
		if is_tree_buffer(current) then
			set_tree_enabled(false)
			close_tree()
			M.normalize_layout()
			M.focus_editor_window()
			return
		end

		focus_tree()
		return
	end

	set_tree_enabled(true)
	open_tree()
	M.normalize_layout()
	M.focus_editor_window()
end

return M
