local workspace = require("config.workspace")

local results = {}
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

local function ok(name, condition, detail)
	if not condition then
		error(name .. ": " .. (detail or "failed"))
	end

	table.insert(results, name)
end

local function file_contains(path, expected)
	local lines = vim.fn.readfile(path)
	return table.concat(lines, "\n"):find(expected, 1, true) ~= nil
end

local function write_file(path, lines)
	vim.fn.mkdir(vim.fs.dirname(path), "p")
	vim.fn.writefile(lines, path)
end

local function hex(value)
	if value == nil then
		return nil
	end

	return string.format("#%06x", value)
end

local function picker(source)
	return Snacks.picker.get({ source = source })[1]
end

local function close_picker(source)
	local active = picker(source)
	if active then
		active:close()
	end
end

local function run_mapping(lhs)
	local map = vim.fn.maparg(lhs, "n", false, true)
	if type(map) ~= "table" or vim.tbl_isempty(map) then
		error("missing mapping for " .. lhs)
	end

	if type(map.callback) == "function" then
		map.callback()
		return
	end

	if type(map.rhs) == "string" and map.rhs ~= "" then
		vim.api.nvim_feedkeys(vim.keycode(map.rhs), "m", false)
		return
	end

	error("mapping for " .. lhs .. " has no callable target")
end

local function tree_window()
	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local bufnr = vim.api.nvim_win_get_buf(winid)
		if vim.bo[bufnr].filetype == "NvimTree" then
			return winid, bufnr
		end
	end
end

local function listed_buffer_names()
	local names = {}
	for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
		table.insert(names, vim.api.nvim_buf_get_name(info.bufnr))
	end
	return names
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

local function listed_file_buffers()
	local buffers = {}
	for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
		if require("config.workspace").is_real_file_buffer(info.bufnr) then
			table.insert(buffers, info.bufnr)
		end
	end
	return buffers
end

local function layout_state()
	local wins = vim.api.nvim_tabpage_list_wins(0)
	local has_editor = false
	local has_explorer = false

	for _, winid in ipairs(wins) do
		local bufnr = vim.api.nvim_win_get_buf(winid)
		if vim.bo[bufnr].filetype == "NvimTree" then
			has_explorer = true
		elseif vim.bo[bufnr].filetype == "" and vim.bo[bufnr].buftype == "" then
			has_editor = true
		end
	end

	return {
		wins = wins,
		has_editor = has_editor,
		has_explorer = has_explorer,
	}
end

ok("snacks loaded", pcall(require, "snacks"))
ok("which-key loaded", pcall(require, "which-key"))
ok("conform loaded", pcall(require, "conform"))
ok("blink loaded", pcall(require, "blink.cmp"))
ok("nvim-tree loaded", pcall(require, "nvim-tree"))
ok("lualine loaded", pcall(require, "lualine"))
ok("bufferline command", vim.fn.exists(":BufferLineCycleNext") == 2)
ok("diffview command removed", vim.fn.exists(":DiffviewOpen") == 0)
ok(
	"mini statusline removed",
	not file_contains(vim.fn.stdpath("config") .. "/lua/plugins/editor.lua", "mini.statusline")
)
ok("snacks bigfile is enabled", Snacks.config.bigfile.enabled == true)
ok("snacks words is enabled", Snacks.config.words.enabled == true)
ok("snacks gitbrowse is enabled", Snacks.config.gitbrowse.enabled == true)
ok("mouse is enabled globally", vim.o.mouse == "a")
ok("mousemodel supports selection", vim.o.mousemodel == "extend")
ok("mousescroll is tuned", vim.o.mousescroll == "ver:3,hor:6")
ok("autoread is enabled", vim.o.autoread == true)
ok("lazygit mouse events are enabled", file_contains(repo_root .. "/lazygit/config.yml", "mouseEvents: true"))

local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
local tree_hl = vim.api.nvim_get_hl(0, { name = "NvimTreeNormal", link = false })
local float_hl = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
local border_hl = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })
local keyword_hl = vim.api.nvim_get_hl(0, { name = "Keyword", link = false })

ok("normal background is transparent", normal_hl.bg == nil)
ok("tree background is transparent", tree_hl.bg == nil)
ok("float background is opaque", float_hl.bg ~= nil)
ok("float border uses fluorescent green accent", hex(border_hl.fg) == "#39ff14")
ok("keyword color uses vscode purple", hex(keyword_hl.fg) == "#c586c0")

local ensured_servers = require("config.lsp").ensure_installed_servers()
local blink_mappings = require("blink.cmp.keymap").get_mappings(require("blink.cmp.config").keymap, "default")

ok(
	"blink tab completion is customized",
	type(blink_mappings["<Tab>"]) == "table" and type(blink_mappings["<Tab>"][1]) == "function"
)
ok("ctrl-z undo is mapped in insert mode", vim.fn.maparg("<C-z>", "i") ~= "")
ok("rust analyzer is included when rust tooling exists", vim.tbl_contains(ensured_servers, "rust_analyzer"))
ok("gopls is included when go exists", vim.tbl_contains(ensured_servers, "gopls"))

local health_buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_name(health_buf, vim.fn.getcwd() .. "/Untitled-snacks-health")
vim.bo[health_buf].filetype = "checkhealth"
ok("checkhealth buffer is not autosaved as a file", not workspace.is_real_file_buffer(health_buf))
vim.api.nvim_buf_delete(health_buf, { force = true })

workspace.open_startup_layout({
	file = vim.fn.getcwd(),
	buf = vim.api.nvim_get_current_buf(),
})

vim.wait(1500, function()
	local state = layout_state()
	return tree_window() ~= nil and state.has_editor and state.has_explorer and vim.bo.filetype == ""
end, 20)

local state = layout_state()
local tree_win = tree_window()

ok("folder layout opens explorer and editor", state.has_editor and state.has_explorer)
ok("startup focuses editor", vim.bo.filetype == "", "focus stayed in explorer")
ok("explorer uses fixed sidebar", tree_win and vim.api.nvim_win_get_width(tree_win) == 34)
local tree_left_release = tree_win
	and vim.api.nvim_buf_call(vim.api.nvim_win_get_buf(tree_win), function()
		return vim.fn.maparg("<LeftRelease>", "n", false, true)
	end)
ok("tree exposes single-click mouse open", tree_left_release and tree_left_release.buffer == 1)

run_mapping("<leader>f")
vim.wait(1000, function()
	return picker("grep") ~= nil
end, 20)
ok("leader f opens workspace grep", picker("grep") ~= nil)
ok("workspace grep is centered lower", picker("grep").opts.layout.layout.row == 0.3)
ok("workspace grep uses overlay border", picker("grep").opts.layout.layout.border == "rounded")
ok("workspace grep is opaque", picker("grep").opts.layout.layout.backdrop == false)
close_picker("grep")

run_mapping("<C-p>")
vim.wait(1000, function()
	return picker("smart") ~= nil
end, 20)
ok("ctrl-p opens smart picker", picker("smart") ~= nil)
close_picker("smart")

run_mapping("<leader>n")
vim.wait(1000, function()
	return vim.bo.filetype == "snacks_notif_history"
end, 20)
ok("leader n opens notification history", vim.bo.filetype == "snacks_notif_history")
vim.cmd("close")

run_mapping("<leader>:")
vim.wait(1000, function()
	return picker("command_history") ~= nil
end, 20)
ok("leader colon opens command history", picker("command_history") ~= nil)
close_picker("command_history")

run_mapping("<C-b>")
vim.wait(1000, function()
	return vim.bo.filetype == "NvimTree"
end, 20)
ok("ctrl-b focuses tree", vim.bo.filetype == "NvimTree")

local close_target_one = vim.fn.tempname() .. ".lua"
local close_target_two = vim.fn.tempname() .. ".lua"
vim.fn.writefile({ "local close_target = 1" }, close_target_one)
vim.fn.writefile({ "local close_target = 2" }, close_target_two)
vim.cmd("edit " .. close_target_one)
local close_target_one_buf = vim.api.nvim_get_current_buf()
vim.cmd("edit " .. close_target_two)
local close_target_two_buf = vim.api.nvim_get_current_buf()
run_mapping("<C-b>")
vim.wait(1000, function()
	return vim.bo.filetype == "NvimTree"
end, 20)
workspace.close_buffer(close_target_one_buf)
vim.wait(500, function()
	local tree = tree_window()
	return tree ~= nil and vim.api.nvim_get_current_buf() ~= close_target_one_buf
end, 20)
local tree_after_inactive_close = tree_window()
ok("closing inactive tab while tree is focused keeps tree visible", tree_after_inactive_close ~= nil)
ok(
	"closing inactive tab while tree is focused keeps tree width stable",
	tree_after_inactive_close and vim.api.nvim_win_get_width(tree_after_inactive_close) == 34
)
ok(
	"closing inactive tab while tree is focused does not replace tree buffer",
	tree_after_inactive_close and vim.bo[vim.api.nvim_win_get_buf(tree_after_inactive_close)].filetype == "NvimTree"
)
ok("closing inactive tab while tree is focused preserves active file", vim.api.nvim_buf_is_valid(close_target_two_buf))
ok("leader gs mapping exists", vim.fn.maparg("<leader>gs", "n") ~= "")
ok("leader gl mapping exists", vim.fn.maparg("<leader>gl", "n") ~= "")
ok("leader go mapping exists", vim.fn.maparg("<leader>go", "n") ~= "")
ok("leader sw mapping exists", vim.fn.maparg("<leader>sw", "n") ~= "")
ok("double bracket words jump exists", vim.fn.maparg("]]", "n") ~= "")
ok("double bracket reverse words jump exists", vim.fn.maparg("[[", "n") ~= "")

if vim.bo.filetype ~= "NvimTree" then
	run_mapping("<C-b>")
	vim.wait(1000, function()
		return vim.bo.filetype == "NvimTree"
	end, 20)
end

workspace.toggle_tree()
workspace.focus_editor_window()

local autosave_file = vim.fn.tempname() .. ".lua"
vim.fn.writefile({ "local value = 1" }, autosave_file)
vim.cmd("edit " .. autosave_file)
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "local value = 2" })
workspace.schedule_autosave(vim.api.nvim_get_current_buf(), 50)
vim.wait(500, function()
	return file_contains(autosave_file, "local value = 2")
end, 10)
ok("autosave writes file", file_contains(autosave_file, "local value = 2"))

local external_file = vim.fn.tempname() .. ".lua"
vim.fn.writefile({ "local external_value = 1" }, external_file)
vim.cmd("edit " .. external_file)
local external_buf = vim.api.nvim_get_current_buf()
vim.wait(1200)
vim.fn.writefile({ "local external_value = 2" }, external_file)
workspace.refresh_changed_files()
vim.wait(1000, function()
	return vim.api.nvim_buf_get_lines(external_buf, 0, -1, false)[1] == "local external_value = 2"
end, 20)
ok(
	"external file changes reload on focus",
	vim.api.nvim_buf_get_lines(external_buf, 0, -1, false)[1] == "local external_value = 2"
)

local js_file = vim.fn.tempname() .. ".js"
vim.fn.writefile({ "const value={foo:'bar'}" }, js_file)
vim.cmd("edit " .. js_file)
vim.cmd("write")
vim.wait(1000, function()
	return file_contains(js_file, 'const value = { foo: "bar" };')
end, 20)
ok("javascript format on save", file_contains(js_file, 'const value = { foo: "bar" };'))

local py_file = vim.fn.tempname() .. ".py"
vim.fn.writefile({ "x=1", "print( x )" }, py_file)
vim.cmd("edit " .. py_file)
vim.cmd("write")
vim.wait(1000, function()
	return file_contains(py_file, "x = 1") and file_contains(py_file, "print(x)")
end, 20)
ok("python format on save", file_contains(py_file, "x = 1") and file_contains(py_file, "print(x)"))

for _, bufnr in ipairs(listed_file_buffers()) do
	pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
end
workspace.normalize_layout()

vim.cmd("tabnew")
workspace.open_startup_layout({
	file = vim.fn.getcwd(),
	buf = vim.api.nvim_get_current_buf(),
})
vim.wait(1500, function()
	local isolated_tree = tree_window()
	local isolated_state = layout_state()
	return isolated_tree ~= nil and isolated_state.has_editor and isolated_state.has_explorer
end, 20)

local close_file = vim.fn.tempname() .. ".lua"
vim.fn.writefile({ "local close_me = true" }, close_file)
vim.cmd("edit " .. close_file)
workspace.focus_editor_window()
workspace.close_current_buffer()
vim.wait(500, function()
	workspace.normalize_layout()
	return tree_window() ~= nil and vim.bo.filetype == "" and #listed_file_buffers() == 0
end, 20)
ok("closing last file keeps blank editor", vim.bo.filetype == "" and vim.bo.buftype == "")
ok("closing last file keeps tree visible", tree_window() ~= nil)
local isolated_tree_win = tree_window()
ok(
	"closing last file keeps tree width stable",
	isolated_tree_win and vim.api.nvim_win_get_width(isolated_tree_win) == 34
)
ok("closing last file leaves no visible tab artifacts", #visible_tab_buffers() == 0)
vim.cmd("tabclose")

local python_project = vim.fn.tempname()
vim.fn.mkdir(python_project, "p")
write_file(python_project .. "/pyproject.toml", { "[project]", 'name = "demo"' })
write_file(python_project .. "/.venv/bin/python", { "#!/usr/bin/env python3" })

local pyright_workspace = require("config.lsp").python_workspace(python_project .. "/app.py")

ok(
	"python workspace detects local venv",
	pyright_workspace.root == python_project and pyright_workspace.venv == python_project .. "/.venv"
)
ok("python workspace sets interpreter path", pyright_workspace.python == python_project .. "/.venv/bin/python")
ok(
	"python workspace exports virtualenv",
	pyright_workspace.cmd_env and pyright_workspace.cmd_env.VIRTUAL_ENV == python_project .. "/.venv"
)

local node_project = vim.fn.tempname()
vim.fn.mkdir(node_project, "p")
write_file(node_project .. "/package.json", { '{ "name": "demo" }' })
write_file(node_project .. "/node_modules/.bin/prettier", { "#!/usr/bin/env node" })
write_file(node_project .. "/node_modules/typescript/lib/typescript.js", { "module.exports = {}" })

local node_workspace = require("config.lsp").node_workspace(node_project .. "/src/index.ts")

ok("node workspace detects package root", node_workspace.root == node_project)
ok("node workspace detects local bin", node_workspace.local_bin == node_project .. "/node_modules/.bin")
ok("node workspace detects tsdk", node_workspace.tsdk == node_project .. "/node_modules/typescript/lib")

local ts_config = {}
require("config.lsp").apply_node_workspace(ts_config, node_project .. "/src/index.ts", { tsdk = true })

ok(
	"node workspace exports local bin on path",
	ts_config.cmd_env and ts_config.cmd_env.PATH:find(node_project .. "/node_modules/.bin", 1, true) == 1
)
ok(
	"node workspace injects tsdk into init options",
	vim.tbl_get(ts_config, "init_options", "typescript", "tsdk") == node_project .. "/node_modules/typescript/lib"
)

local rust_project = vim.fn.tempname()
vim.fn.mkdir(rust_project, "p")
write_file(rust_project .. "/Cargo.toml", { "[package]", 'name = "demo"', 'version = "0.1.0"' })

local rust_workspace = require("config.lsp").rust_workspace(rust_project .. "/src/main.rs")

ok("rust workspace detects cargo root", rust_workspace.root == rust_project)
ok("rust workspace exposes cargo manifest", rust_workspace.cargo_toml == rust_project .. "/Cargo.toml")

local go_project = vim.fn.tempname()
vim.fn.mkdir(go_project, "p")
write_file(go_project .. "/go.mod", { "module example.com/demo", "", "go 1.24.0" })

local go_workspace = require("config.lsp").go_workspace(go_project .. "/main.go")

ok("go workspace detects module root", go_workspace.root == go_project)
ok("go workspace exposes go.mod", go_workspace.go_mod == go_project .. "/go.mod")

vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua")
vim.wait(3000, function()
	return #vim.lsp.get_clients({ bufnr = 0 }) > 0
end, 50)
ok("lua lsp attached", #vim.lsp.get_clients({ bufnr = 0 }) > 0)
ok("definition call", pcall(vim.lsp.buf.definition))
ok("hover call", pcall(vim.lsp.buf.hover))
ok("references call", pcall(vim.lsp.buf.references))

print("SMOKE TEST PASSED")
print(table.concat(results, "\n"))
