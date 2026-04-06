local workspace = require("config.workspace")
local repo_root = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.stdpath("config")), ":h")

require("lazy").load({
	plugins = {
		"blink.cmp",
		"bufferline.nvim",
		"conform.nvim",
		"lualine.nvim",
		"mini.nvim",
		"nvim-tree.lua",
		"which-key.nvim",
	},
})

do
	local ok, frecency = pcall(require, "snacks.picker.core.frecency")
	if ok then
		frecency.visit_buf = function()
			return false
		end
	end
end

local cases = {}
local results = {}
local failures = {}
local picker_sources = {
	"smart",
	"grep",
	"lines",
	"buffers",
	"commands",
	"diagnostics",
	"pickers",
	"recent",
}

local function expect(condition, message)
	if not condition then
		error(message or "assertion failed", 0)
	end
end

local function case(name, fn)
	table.insert(cases, { name = name, fn = fn })
end

local function tree_window()
	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local bufnr = vim.api.nvim_win_get_buf(winid)
		if vim.bo[bufnr].filetype == "NvimTree" then
			return winid, bufnr
		end
	end
end

local function editor_windows()
	local windows = {}

	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local bufnr = vim.api.nvim_win_get_buf(winid)
		if vim.api.nvim_win_get_config(winid).relative == "" and vim.bo[bufnr].filetype ~= "NvimTree" then
			table.insert(windows, {
				winid = winid,
				bufnr = bufnr,
				name = vim.api.nvim_buf_get_name(bufnr),
				filetype = vim.bo[bufnr].filetype,
				buftype = vim.bo[bufnr].buftype,
				width = vim.api.nvim_win_get_width(winid),
			})
		end
	end

	return windows
end

local function current_editor_state()
	local bufnr = vim.api.nvim_get_current_buf()
	return {
		bufnr = bufnr,
		name = vim.api.nvim_buf_get_name(bufnr),
		filetype = vim.bo[bufnr].filetype,
		buftype = vim.bo[bufnr].buftype,
	}
end

local function primary_editor_state()
	local editors = editor_windows()
	local editor = editors[1]
	expect(editor ~= nil, "missing editor window")

	return {
		bufnr = editor.bufnr,
		name = editor.name,
		filetype = editor.filetype,
		buftype = editor.buftype,
	}
end

local function picker(source)
	return Snacks.picker.get({ source = source })[1]
end

local function close_all_pickers()
	for _, source in ipairs(picker_sources) do
		local active = picker(source)
		if active then
			active:close()
		end
	end
end

local function run_mapping(lhs)
	local map = vim.fn.maparg(lhs, "n", false, true)
	expect(type(map) == "table" and not vim.tbl_isempty(map), "missing mapping for " .. lhs)

	if type(map.callback) == "function" then
		map.callback()
		return
	end

	if type(map.rhs) == "string" and map.rhs ~= "" then
		vim.api.nvim_feedkeys(vim.keycode(map.rhs), "m", false)
		return
	end

	error("mapping for " .. lhs .. " has no callable target", 0)
end

local function visible_tab_buffers()
	local config = require("bufferline.config")
	local filter = config.options.custom_filter
	local buffers = {}

	for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
		if not filter or filter(info.bufnr) then
			table.insert(buffers, info.bufnr)
		end
	end

	return buffers
end

local function current_tab_has_directory_buffer()
	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local bufnr = vim.api.nvim_win_get_buf(winid)
		local name = vim.api.nvim_buf_get_name(bufnr)
		if name ~= "" and vim.fn.isdirectory(name) == 1 then
			return true
		end
	end

	return false
end

local function listed_real_file_buffers()
	local buffers = {}
	for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
		if workspace.is_real_file_buffer(info.bufnr) then
			table.insert(buffers, info.bufnr)
		end
	end
	return buffers
end

local function delete_buffer_if_possible(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
end

local function close_extra_tabs()
	while #vim.api.nvim_list_tabpages() > 1 do
		vim.cmd("tablast")
		pcall(vim.cmd, "tabclose!")
	end

	vim.cmd("tabfirst")
end

local function teardown()
	close_extra_tabs()

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(bufnr) then
			local name = vim.api.nvim_buf_get_name(bufnr)
			if workspace.is_real_file_buffer(bufnr) or name == "" or (name ~= "" and vim.fn.isdirectory(name) == 1) then
				delete_buffer_if_possible(bufnr)
			end
		end
	end

	workspace.normalize_layout()
	workspace.normalize_layout()
	workspace.ensure_blank_editor()
	workspace.focus_editor_window()
end

local function with_workspace(start_file, fn)
	teardown()
	vim.cmd("tabnew")

	local ok, err = xpcall(function()
		local start_path = start_file or vim.fn.getcwd()
		local absolute_path = start_path ~= "" and vim.fn.fnamemodify(start_path, ":p") or ""
		local file_start = absolute_path ~= "" and vim.fn.isdirectory(absolute_path) == 0

		if file_start then
			vim.cmd("edit " .. absolute_path)
		end

		workspace.open_startup_layout({
			file = start_path,
			buf = vim.api.nvim_get_current_buf(),
		})

		vim.wait(1500, function()
			local tree = tree_window()
			local editors = editor_windows()
			local current = vim.api.nvim_get_current_buf()
			if file_start then
				return tree ~= nil and #editors == 1 and workspace.is_real_file_buffer(current)
			end
			return tree ~= nil and #editors == 1 and vim.bo.filetype == ""
		end, 20)

		workspace.normalize_layout()
		workspace.focus_editor_window()
		fn()
	end, debug.traceback)

	pcall(vim.cmd, "tabclose!")
	teardown()

	if not ok then
		error(err, 0)
	end
end

local function with_empty_workspace(fn)
	teardown()
	vim.cmd("tabnew")

	local ok, err = xpcall(function()
		workspace.open_startup_layout({
			file = "",
			buf = vim.api.nvim_get_current_buf(),
		})

		vim.wait(1500, function()
			local tree = tree_window()
			return tree ~= nil and #editor_windows() == 1 and vim.bo.filetype == ""
		end, 20)

		workspace.normalize_layout()
		workspace.focus_editor_window()
		fn()
	end, debug.traceback)

	pcall(vim.cmd, "tabclose!")
	teardown()

	if not ok then
		error(err, 0)
	end
end

local function open_files(count, extension, lines)
	local files = {}
	local dir = vim.fn.tempname()

	vim.fn.mkdir(dir, "p")

	for index = 1, count do
		local path = string.format("%s/file_%02d%s", dir, index, extension)
		vim.fn.writefile(lines(index), path)
		vim.cmd("edit " .. path)
		table.insert(files, vim.api.nvim_get_current_buf())
	end

	return files
end

local function assert_workspace_shell(tree_expected, visible_tabs_expected, message_prefix)
	local prefix = message_prefix and (message_prefix .. ": ") or ""
	local tree = tree_window()
	local editors = editor_windows()

	expect(#editors == 1, prefix .. "expected exactly one editor window")
	expect(not current_tab_has_directory_buffer(), prefix .. "directory buffer leaked into current tab")

	if tree_expected then
		expect(tree ~= nil, prefix .. "tree should be visible")
		expect(vim.api.nvim_win_get_width(tree) == 34, prefix .. "tree width should stay fixed")
		expect(#vim.api.nvim_tabpage_list_wins(0) == 2, prefix .. "expected tree + editor layout")
	else
		expect(tree == nil, prefix .. "tree should be hidden")
		expect(#vim.api.nvim_tabpage_list_wins(0) == 1, prefix .. "expected single editor layout")
	end

	expect(#visible_tab_buffers() == visible_tabs_expected, prefix .. "unexpected visible tab count")
end

local function assert_picker_overlay(source, expected_row)
	local active = picker(source)
	expect(active ~= nil, source .. " picker did not open")
	expect(active.opts.layout.layout.row == expected_row, source .. " picker row drifted")
	expect(active.opts.layout.layout.border == "rounded", source .. " picker border drifted")
	expect(active.opts.layout.layout.backdrop == false, source .. " picker backdrop drifted")
	active:close()
	vim.wait(200, function()
		return picker(source) == nil
	end, 20)
	workspace.focus_editor_window()
	expect(vim.bo.filetype ~= "NvimTree", source .. " picker closed into tree focus")
end

for _, lhs in ipairs({
	"<C-p>",
	"<C-f>",
	"<leader>f",
	"<leader>b",
	"<leader>p",
	"<leader>d",
	"<leader>s",
	"<leader><space>",
	"<C-b>",
}) do
	case("keymap_exists_" .. lhs, function()
		local map = vim.fn.maparg(lhs, "n", false, true)
		expect(type(map) == "table" and not vim.tbl_isempty(map), "missing mapping for " .. lhs)
	end)
end

for _, mapping in ipairs({
	{ lhs = "<C-s>", mode = "n" },
	{ lhs = "<C-z>", mode = "n" },
	{ lhs = "<C-z>", mode = "i" },
	{ lhs = "<C-z>", mode = "v" },
	{ lhs = "<Tab>", mode = "n" },
	{ lhs = "<S-Tab>", mode = "n" },
	{ lhs = "<leader>.", mode = "n" },
	{ lhs = "<leader>g", mode = "n" },
}) do
	case("keymap_exists_" .. mapping.mode .. "_" .. mapping.lhs, function()
		expect(
			vim.fn.maparg(mapping.lhs, mapping.mode) ~= "",
			"missing " .. mapping.mode .. " mapping for " .. mapping.lhs
		)
	end)
end

case("startup_folder_tree_and_editor", function()
	with_workspace(vim.fn.getcwd(), function()
		assert_workspace_shell(true, 0, "folder startup")
		expect(vim.bo.filetype == "", "folder startup should focus editor")
	end)
end)

case("startup_empty_tree_and_editor", function()
	with_empty_workspace(function()
		assert_workspace_shell(true, 0, "empty startup")
		expect(vim.bo.filetype == "", "empty startup should focus editor")
	end)
end)

case("startup_file_tree_and_editor", function()
	local file = vim.fn.tempname() .. ".lua"
	vim.fn.writefile({ "local startup = true" }, file)
	with_workspace(file, function()
		assert_workspace_shell(true, 1, "file startup")
		expect(workspace.is_real_file_buffer(vim.api.nvim_get_current_buf()), "file startup should focus the file")
	end)
end)

case("tree_toggle_hide_from_editor", function()
	with_workspace(vim.fn.getcwd(), function()
		run_mapping("<C-b>")
		vim.wait(500, function()
			return vim.bo.filetype == "NvimTree"
		end, 20)
		run_mapping("<C-b>")
		vim.wait(500, function()
			return tree_window() == nil
		end, 20)
		assert_workspace_shell(false, 0, "tree hide")
	end)
end)

case("tree_toggle_restore_after_hide", function()
	with_workspace(vim.fn.getcwd(), function()
		run_mapping("<C-b>")
		vim.wait(500, function()
			return vim.bo.filetype == "NvimTree"
		end, 20)
		run_mapping("<C-b>")
		vim.wait(500, function()
			return tree_window() == nil
		end, 20)
		run_mapping("<C-b>")
		vim.wait(500, function()
			return tree_window() ~= nil
		end, 20)
		assert_workspace_shell(true, 0, "tree restore")
		expect(vim.bo.filetype == "", "tree restore should refocus the editor")
	end)
end)

case("search_workspace_grep_overlay", function()
	with_workspace(vim.fn.getcwd(), function()
		run_mapping("<leader>f")
		vim.wait(1000, function()
			return picker("grep") ~= nil
		end, 20)
		assert_picker_overlay("grep", 0.3)
	end)
end)

case("search_file_picker_overlay", function()
	with_workspace(vim.fn.getcwd(), function()
		run_mapping("<C-p>")
		vim.wait(1000, function()
			return picker("smart") ~= nil
		end, 20)
		assert_picker_overlay("smart", 0.3)
	end)
end)

case("search_current_file_overlay", function()
	local file = vim.fn.tempname() .. ".lua"
	vim.fn.writefile({ "local current = 1", "local next_value = 2" }, file)
	with_workspace(file, function()
		run_mapping("<C-f>")
		vim.wait(1000, function()
			return picker("lines") ~= nil
		end, 20)
		assert_picker_overlay("lines", 0.3)
	end)
end)

case("search_buffer_picker_overlay", function()
	with_workspace(vim.fn.getcwd(), function()
		open_files(2, ".lua", function(index)
			return { "local buffer_case = " .. index }
		end)
		run_mapping("<leader>b")
		vim.wait(1000, function()
			return picker("buffers") ~= nil
		end, 20)
		assert_picker_overlay("buffers", 0.3)
	end)
end)

case("search_command_palette_overlay", function()
	with_workspace(vim.fn.getcwd(), function()
		run_mapping("<leader>p")
		vim.wait(1000, function()
			return picker("commands") ~= nil
		end, 20)
		assert_picker_overlay("commands", 0.3)
	end)
end)

case("snacks_high_value_modules_enabled", function()
	expect(Snacks.config.bigfile.enabled == true, "snacks bigfile should be enabled")
	expect(Snacks.config.words.enabled == true, "snacks words should be enabled")
	expect(Snacks.config.gitbrowse.enabled == true, "snacks gitbrowse should be enabled")
end)

case("checkhealth_buffers_are_not_treated_as_real_files", function()
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(buf, vim.fn.getcwd() .. "/Untitled-snacks-health")
	vim.bo[buf].filetype = "checkhealth"
	expect(not workspace.is_real_file_buffer(buf), "checkhealth buffer should not be autosaved")
	vim.api.nvim_buf_delete(buf, { force = true })
end)

case("search_notification_history_overlay", function()
	with_workspace(vim.fn.getcwd(), function()
		run_mapping("<leader>n")
		vim.wait(1000, function()
			return vim.bo.filetype == "snacks_notif_history"
		end, 20)
		expect(vim.bo.filetype == "snacks_notif_history", "notification history did not open")
		vim.cmd("close")
	end)
end)

case("search_command_history_overlay", function()
	with_workspace(vim.fn.getcwd(), function()
		run_mapping("<leader>:")
		vim.wait(1000, function()
			return picker("command_history") ~= nil
		end, 20)
		assert_picker_overlay("command_history", 0.3)
	end)
end)

case("mouse_core_options_enabled", function()
	expect(vim.o.mouse == "a", "mouse should be enabled everywhere")
	expect(vim.o.mousemodel == "extend", "mousemodel should support selection")
	expect(vim.o.mousescroll == "ver:3,hor:6", "mousescroll should be tuned")
end)

case("tree_mouse_click_mapping_exists", function()
	with_workspace(vim.fn.getcwd(), function()
		local tree, tree_buf = tree_window()
		expect(tree ~= nil, "tree window missing")
		local left_release = vim.api.nvim_buf_call(tree_buf, function()
			return vim.fn.maparg("<LeftRelease>", "n", false, true)
		end)
		expect(type(left_release) == "table" and left_release.buffer == 1, "tree mouse mapping missing")
	end)
end)

case("bufferline_mouse_focuses_editor_not_tree", function()
	with_workspace(vim.fn.getcwd(), function()
		local buffers = open_files(2, ".lua", function(index)
			return { "local mouse_case = " .. index }
		end)
		run_mapping("<C-b>")
		vim.wait(300, function()
			return vim.bo.filetype == "NvimTree"
		end, 20)
		require("config.workspace").focus_buffer(buffers[2])
		vim.wait(300, function()
			return vim.api.nvim_get_current_buf() == buffers[2]
		end, 20)
		expect(vim.bo.filetype ~= "NvimTree", "buffer click should focus an editor")
		assert_workspace_shell(true, 2, "bufferline mouse focus")
	end)
end)

case("lazygit_mouse_events_enabled", function()
	local config_path = repo_root .. "/lazygit/config.yml"
	local config = table.concat(vim.fn.readfile(config_path), "\n")
	expect(config:find("mouseEvents: true", 1, true) ~= nil, "lazygit mouse events should be enabled")
end)

case("snacks_superpower_keymaps_exist", function()
	expect(vim.fn.maparg("<leader>gs", "n") ~= "", "git status picker mapping missing")
	expect(vim.fn.maparg("<leader>gl", "n") ~= "", "git log picker mapping missing")
	expect(vim.fn.maparg("<leader>go", "n") ~= "", "git browse mapping missing")
	expect(vim.fn.maparg("<leader>sw", "n") ~= "", "grep word mapping missing")
	expect(vim.fn.maparg("]]", "n") ~= "", "next reference mapping missing")
	expect(vim.fn.maparg("[[", "n") ~= "", "previous reference mapping missing")
end)

case("close_inactive_buffer_keeps_tree_intact", function()
	with_workspace(vim.fn.getcwd(), function()
		local buffers = open_files(2, ".lua", function(index)
			return { "local close_tree_case = " .. index }
		end)

		run_mapping("<C-b>")
		vim.wait(300, function()
			return vim.bo.filetype == "NvimTree"
		end, 20)

		workspace.close_buffer(buffers[1])
		vim.wait(500, function()
			local tree = tree_window()
			return tree ~= nil and #editor_windows() == 1
		end, 20)

		assert_workspace_shell(true, 1, "tree focused close")
		expect(vim.bo.filetype == "NvimTree", "tree focused close should keep focus in the tree")
	end)
end)

case("search_recent_picker_overlay", function()
	with_workspace(vim.fn.getcwd(), function()
		run_mapping("<leader>h")
		vim.wait(1000, function()
			return picker("recent") ~= nil
		end, 20)
		assert_picker_overlay("recent", 0.3)
	end)
end)

case("search_search_everywhere_overlay", function()
	with_workspace(vim.fn.getcwd(), function()
		run_mapping("<leader>s")
		vim.wait(1000, function()
			return picker("pickers") ~= nil
		end, 20)
		assert_picker_overlay("pickers", 0.3)
	end)
end)

case("search_space_space_overlay", function()
	with_workspace(vim.fn.getcwd(), function()
		run_mapping("<leader><space>")
		vim.wait(1000, function()
			return picker("pickers") ~= nil
		end, 20)
		assert_picker_overlay("pickers", 0.3)
	end)
end)

case("autosave_writes_to_disk", function()
	with_workspace(vim.fn.getcwd(), function()
		local file = vim.fn.tempname() .. ".lua"
		vim.fn.writefile({ "local value = 1" }, file)
		vim.cmd("edit " .. file)
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "local value = 2" })
		workspace.schedule_autosave(vim.api.nvim_get_current_buf(), 50)
		vim.wait(500, function()
			return table.concat(vim.fn.readfile(file), "\n"):find("local value = 2", 1, true) ~= nil
		end, 20)
		expect(
			table.concat(vim.fn.readfile(file), "\n"):find("local value = 2", 1, true) ~= nil,
			"autosave did not write"
		)
	end)
end)

case("external_file_changes_reload_clean_buffers", function()
	with_workspace(vim.fn.getcwd(), function()
		local file = vim.fn.tempname() .. ".lua"
		vim.fn.writefile({ "local external_case = 1" }, file)
		vim.cmd("edit " .. file)
		local bufnr = vim.api.nvim_get_current_buf()
		vim.wait(1200)
		vim.fn.writefile({ "local external_case = 2" }, file)
		workspace.refresh_changed_files()
		vim.wait(500, function()
			return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)[1] == "local external_case = 2"
		end, 20)
		expect(
			vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)[1] == "local external_case = 2",
			"external file changes did not reload"
		)
	end)
end)

case("format_javascript_on_save", function()
	with_workspace(vim.fn.getcwd(), function()
		local file = vim.fn.tempname() .. ".js"
		vim.fn.writefile({ "const value={foo:'bar'}" }, file)
		vim.cmd("edit " .. file)
		vim.cmd("write")
		vim.wait(1000, function()
			return table.concat(vim.fn.readfile(file), "\n"):find('const value = { foo: "bar" };', 1, true) ~= nil
		end, 20)
		expect(
			table.concat(vim.fn.readfile(file), "\n"):find('const value = { foo: "bar" };', 1, true) ~= nil,
			"javascript formatter drifted"
		)
	end)
end)

case("format_python_on_save", function()
	with_workspace(vim.fn.getcwd(), function()
		local file = vim.fn.tempname() .. ".py"
		vim.fn.writefile({ "x=1", "print( x )" }, file)
		vim.cmd("edit " .. file)
		vim.cmd("write")
		vim.wait(1000, function()
			local text = table.concat(vim.fn.readfile(file), "\n")
			return text:find("x = 1", 1, true) ~= nil and text:find("print%(x%)") ~= nil
		end, 20)
		local text = table.concat(vim.fn.readfile(file), "\n")
		expect(text:find("x = 1", 1, true) ~= nil and text:find("print%(x%)") ~= nil, "python formatter drifted")
	end)
end)

case("python_workspace_picks_dot_venv", function()
	local root = vim.fn.tempname()
	vim.fn.mkdir(root, "p")
	vim.fn.writefile({ "[project]", 'name = "demo"' }, root .. "/pyproject.toml")
	vim.fn.mkdir(root .. "/.venv/bin", "p")
	vim.fn.writefile({ "#!/usr/bin/env python3" }, root .. "/.venv/bin/python")
	local workspace_info = require("config.lsp").python_workspace(root .. "/app.py")
	expect(workspace_info.root == root, "pyright root drifted")
	expect(workspace_info.venv == root .. "/.venv", "dot venv not detected")
	expect(workspace_info.python == root .. "/.venv/bin/python", "dot venv python drifted")
end)

case("python_workspace_picks_venv", function()
	local root = vim.fn.tempname()
	vim.fn.mkdir(root, "p")
	vim.fn.writefile({ "[project]", 'name = "demo"' }, root .. "/pyproject.toml")
	vim.fn.mkdir(root .. "/venv/bin", "p")
	vim.fn.writefile({ "#!/usr/bin/env python3" }, root .. "/venv/bin/python")
	local workspace_info = require("config.lsp").python_workspace(root .. "/src/app.py")
	expect(workspace_info.venv == root .. "/venv", "venv directory not detected")
end)

case("python_workspace_picks_env", function()
	local root = vim.fn.tempname()
	vim.fn.mkdir(root, "p")
	vim.fn.writefile({ "[project]", 'name = "demo"' }, root .. "/pyproject.toml")
	vim.fn.mkdir(root .. "/env/bin", "p")
	vim.fn.writefile({ "#!/usr/bin/env python3" }, root .. "/env/bin/python")
	local workspace_info = require("config.lsp").python_workspace(root .. "/src/app.py")
	expect(workspace_info.venv == root .. "/env", "env directory not detected")
end)

case("node_workspace_detects_local_bin", function()
	local root = vim.fn.tempname()
	vim.fn.mkdir(root .. "/node_modules/.bin", "p")
	vim.fn.mkdir(root .. "/node_modules/typescript/lib", "p")
	vim.fn.writefile({ '{ "name": "demo" }' }, root .. "/package.json")
	vim.fn.writefile({ "#!/usr/bin/env node" }, root .. "/node_modules/.bin/prettier")
	vim.fn.writefile({ "module.exports = {}" }, root .. "/node_modules/typescript/lib/typescript.js")
	local workspace_info = require("config.lsp").node_workspace(root .. "/src/index.ts")
	expect(workspace_info.root == root, "node root drifted")
	expect(workspace_info.local_bin == root .. "/node_modules/.bin", "node local bin drifted")
	expect(workspace_info.tsdk == root .. "/node_modules/typescript/lib", "tsdk drifted")
end)

case("rust_workspace_detects_cargo_root", function()
	local root = vim.fn.tempname()
	vim.fn.mkdir(root, "p")
	vim.fn.writefile({ "[package]", 'name = "demo"', 'version = "0.1.0"' }, root .. "/Cargo.toml")
	local workspace_info = require("config.lsp").rust_workspace(root .. "/src/main.rs")
	expect(workspace_info.root == root, "cargo root drifted")
	expect(workspace_info.cargo_toml == root .. "/Cargo.toml", "cargo manifest drifted")
end)

case("go_workspace_detects_go_mod", function()
	local root = vim.fn.tempname()
	vim.fn.mkdir(root, "p")
	vim.fn.writefile({ "module example.com/demo", "", "go 1.24.0" }, root .. "/go.mod")
	local workspace_info = require("config.lsp").go_workspace(root .. "/main.go")
	expect(workspace_info.root == root, "go root drifted")
	expect(workspace_info.go_mod == root .. "/go.mod", "go.mod drifted")
end)

for count = 1, 6 do
	for current_index = 1, count do
		for _, tree_state in ipairs({ true, false }) do
			local focus_states = tree_state and { "editor", "tree" } or { "editor" }

			for _, focus_state in ipairs(focus_states) do
				case(
					string.format(
						"close_buffers_count_%d_current_%d_tree_%s_focus_%s",
						count,
						current_index,
						tree_state and "visible" or "hidden",
						focus_state
					),
					function()
						with_workspace(vim.fn.getcwd(), function()
							local buffers = open_files(count, ".lua", function(index)
								return { "local close_case = " .. index }
							end)

							vim.cmd("buffer " .. buffers[current_index])
							workspace.focus_editor_window()

							if not tree_state then
								run_mapping("<C-b>")
								vim.wait(300, function()
									return vim.bo.filetype == "NvimTree"
								end, 20)
								run_mapping("<C-b>")
								vim.wait(300, function()
									return tree_window() == nil and #editor_windows() == 1
								end, 20)
							elseif focus_state == "tree" then
								run_mapping("<C-b>")
								vim.wait(300, function()
									return vim.bo.filetype == "NvimTree"
								end, 20)
							end

							if focus_state == "tree" then
								workspace.close_buffer(buffers[current_index])
							else
								workspace.close_current_buffer()
							end
							vim.wait(500, function()
								workspace.normalize_layout()
								local editors = editor_windows()
								local tree = tree_window()
								if tree_state then
									return #editors == 1 and tree ~= nil
								end
								return #editors == 1 and tree == nil
							end, 20)

							local current = focus_state == "tree" and primary_editor_state() or current_editor_state()
							local expected_tabs = count - 1

							assert_workspace_shell(tree_state, expected_tabs, "close flow")

							if count == 1 then
								expect(current.name == "", "last close should land on a blank editor")
								expect(current.filetype == "", "blank editor should keep empty filetype")
								expect(current.buftype == "", "blank editor should keep normal buftype")
								expect(#listed_real_file_buffers() == 0, "last close should remove all real files")
							else
								expect(
									workspace.is_real_file_buffer(current.bufnr),
									"close should keep focus in a real file"
								)
								expect(
									#listed_real_file_buffers() == count - 1,
									"close should remove exactly one real file"
								)
							end
						end)
					end
				)
			end
		end
	end
end

for _, sequence in ipairs({
	{ name = "tree_cycle_from_blank", files = 0 },
	{ name = "tree_cycle_from_one_file", files = 1 },
	{ name = "tree_cycle_from_three_files", files = 3 },
}) do
	case(sequence.name, function()
		with_workspace(vim.fn.getcwd(), function()
			if sequence.files > 0 then
				open_files(sequence.files, ".lua", function(index)
					return { "local tree_cycle = " .. index }
				end)
			end

			run_mapping("<C-b>")
			vim.wait(300, function()
				return vim.bo.filetype == "NvimTree"
			end, 20)
			run_mapping("<C-b>")
			vim.wait(300, function()
				return tree_window() == nil
			end, 20)
			run_mapping("<C-b>")
			vim.wait(300, function()
				return tree_window() ~= nil and #editor_windows() == 1
			end, 20)

			assert_workspace_shell(true, sequence.files, "tree cycle")
		end)
	end)
end

for _, definition in ipairs({
	{ name = "bufferline_filters_placeholders", visible_tabs = 0 },
	{ name = "bufferline_filters_tree", visible_tabs = 0 },
}) do
	case(definition.name, function()
		with_workspace(vim.fn.getcwd(), function()
			assert_workspace_shell(true, definition.visible_tabs, "bufferline filter")
		end)
	end)
end

for _, file_count in ipairs({ 1, 2, 4, 6 }) do
	case("tab_count_matches_files_" .. file_count, function()
		with_workspace(vim.fn.getcwd(), function()
			open_files(file_count, ".lua", function(index)
				return { "local tab_case = " .. index }
			end)
			expect(#visible_tab_buffers() == file_count, "bufferline tab count drifted")
		end)
	end)
end

for _, picker_case in ipairs({
	{ name = "picker_focus_returns_after_grep", lhs = "<leader>f", source = "grep" },
	{ name = "picker_focus_returns_after_smart", lhs = "<C-p>", source = "smart" },
	{ name = "picker_focus_returns_after_commands", lhs = "<leader>p", source = "commands" },
	{ name = "picker_focus_returns_after_recent", lhs = "<leader>h", source = "recent" },
}) do
	case(picker_case.name, function()
		with_workspace(vim.fn.getcwd(), function()
			run_mapping(picker_case.lhs)
			vim.wait(1000, function()
				return picker(picker_case.source) ~= nil
			end, 20)
			close_all_pickers()
			vim.wait(200, function()
				return picker(picker_case.source) == nil
			end, 20)
			expect(vim.bo.filetype ~= "NvimTree", "picker close returned to tree")
			expect(#editor_windows() == 1, "picker close changed editor count")
		end)
	end)
end

for _, current_index in ipairs({ 1, 2, 3, 4, 5 }) do
	case("tab_switching_keeps_single_editor_" .. current_index, function()
		with_workspace(vim.fn.getcwd(), function()
			local buffers = open_files(5, ".lua", function(index)
				return { "local switch_case = " .. index }
			end)
			vim.cmd("buffer " .. buffers[current_index])
			workspace.focus_editor_window()
			run_mapping("<Tab>")
			run_mapping("<S-Tab>")
			assert_workspace_shell(true, 5, "tab switching")
			expect(#editor_windows() == 1, "tab switching created extra editor windows")
		end)
	end)
end

teardown()

for _, definition in ipairs(cases) do
	local ok, err = xpcall(definition.fn, debug.traceback)
	if ok then
		table.insert(results, definition.name)
	else
		table.insert(failures, { name = definition.name, err = err })
	end
end

if #failures > 0 then
	for _, failure in ipairs(failures) do
		print("FAIL " .. failure.name)
		print(failure.err)
	end
	error(string.format("E2E FLOW SUITE FAILED (%d/%d passed)", #results, #cases), 0)
end

print(string.format("E2E FLOW SUITE PASSED (%d cases)", #results))
