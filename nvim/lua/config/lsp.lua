local M = {}
local path_sep = package.config:sub(1, 1) == "\\" and "\\" or "/"
local env_path_sep = path_sep == "\\" and ";" or ":"

local python_root_markers = {
	".venv",
	"venv",
	"pyrightconfig.json",
	"pyproject.toml",
	"setup.py",
	"setup.cfg",
	"requirements.txt",
	"Pipfile",
	".git",
}

local node_root_markers = {
	"package-lock.json",
	"yarn.lock",
	"pnpm-lock.yaml",
	"bun.lockb",
	"bun.lock",
	"package.json",
	"tsconfig.json",
	"jsconfig.json",
	".git",
}

local rust_root_markers = {
	"Cargo.toml",
	"rust-project.json",
	".git",
}

local go_root_markers = {
	"go.work",
	"go.mod",
	".git",
}

local function has_executable(name)
	return vim.fn.executable(name) == 1
end

local function join_paths(...)
	return table.concat({ ... }, path_sep)
end

local function is_directory(path)
	return path ~= nil and path ~= "" and vim.fn.isdirectory(path) == 1
end

local function path_exists(path)
	return path ~= nil and path ~= "" and (vim.uv or vim.loop).fs_stat(path) ~= nil
end

local function merge_path(prefix)
	if not prefix or prefix == "" then
		return vim.env.PATH or ""
	end

	return table.concat({ prefix, vim.env.PATH or "" }, env_path_sep)
end

local function workspace_root(path, markers)
	local start = path and vim.fs.normalize(path) or vim.fn.getcwd()
	if start == "" then
		start = vim.fn.getcwd()
	end

	if not is_directory(start) then
		start = vim.fs.dirname(start)
	end

	return vim.fs.root(start, markers) or start
end

local function python_bin_path(venv_dir)
	if not venv_dir or venv_dir == "" then
		return nil
	end

	local bin_dir = path_sep == "\\" and "Scripts" or "bin"
	local python_name = path_sep == "\\" and "python.exe" or "python"
	local candidate = join_paths(venv_dir, bin_dir, python_name)

	if path_exists(candidate) then
		return candidate
	end
end

local function python_root(path)
	return workspace_root(path, python_root_markers)
end

function M.python_workspace(path)
	local root = python_root(path)
	local candidates = { ".venv", "venv", "env" }
	local venv_dir, venv_name

	for _, name in ipairs(candidates) do
		local candidate = join_paths(root, name)
		if is_directory(candidate) then
			venv_dir = candidate
			venv_name = name
			break
		end
	end

	if not venv_dir and is_directory(vim.env.VIRTUAL_ENV or "") then
		venv_dir = vim.fs.normalize(vim.env.VIRTUAL_ENV)
		venv_name = vim.fs.basename(venv_dir)
	end

	local python_path = python_bin_path(venv_dir)
	local cmd_env

	if python_path and venv_dir then
		cmd_env = {
			VIRTUAL_ENV = venv_dir,
			PATH = merge_path(vim.fs.dirname(python_path)),
		}
	end

	return {
		root = root,
		venv = venv_dir,
		venv_name = venv_name,
		python = python_path,
		cmd_env = cmd_env,
	}
end

function M.apply_python_workspace(config, root_dir)
	local workspace = M.python_workspace(root_dir)
	config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
		python = {
			pythonPath = workspace.python,
			venvPath = workspace.venv and vim.fs.dirname(workspace.venv) or nil,
			venv = workspace.venv_name,
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	})

	if workspace.cmd_env then
		config.cmd_env = vim.tbl_extend("force", config.cmd_env or {}, workspace.cmd_env)
	end

	return workspace
end

function M.node_workspace(path)
	local root = workspace_root(path, node_root_markers)
	local node_modules = join_paths(root, "node_modules")
	local local_bin = join_paths(node_modules, ".bin")
	local tsdk = ""

	if is_directory(node_modules) then
		tsdk = require("lspconfig.util").get_typescript_server_path(root)
	end

	return {
		root = root,
		node_modules = is_directory(node_modules) and node_modules or nil,
		local_bin = is_directory(local_bin) and local_bin or nil,
		tsdk = tsdk ~= "" and tsdk or nil,
		cmd_env = is_directory(local_bin) and { PATH = merge_path(local_bin) } or nil,
	}
end

function M.apply_node_workspace(config, root_dir, opts)
	opts = opts or {}
	local workspace = M.node_workspace(root_dir)

	if workspace.cmd_env then
		config.cmd_env = vim.tbl_extend("force", config.cmd_env or {}, workspace.cmd_env)
	end

	if opts.tsdk and workspace.tsdk then
		config.init_options = vim.tbl_deep_extend("force", config.init_options or {}, {
			typescript = {
				tsdk = workspace.tsdk,
			},
		})

		config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
			typescript = {
				tsdk = workspace.tsdk,
				enablePromptUseWorkspaceTsdk = true,
			},
			javascript = {
				tsdk = workspace.tsdk,
				enablePromptUseWorkspaceTsdk = true,
			},
		})
	end

	return workspace
end

function M.rust_workspace(path)
	local root = workspace_root(path, rust_root_markers)
	local cargo_toml = join_paths(root, "Cargo.toml")
	local rust_project = join_paths(root, "rust-project.json")

	return {
		root = root,
		cargo_toml = path_exists(cargo_toml) and cargo_toml or nil,
		rust_project = path_exists(rust_project) and rust_project or nil,
	}
end

function M.go_workspace(path)
	local root = workspace_root(path, go_root_markers)
	local go_work = join_paths(root, "go.work")
	local go_mod = join_paths(root, "go.mod")

	return {
		root = root,
		go_work = path_exists(go_work) and go_work or nil,
		go_mod = path_exists(go_mod) and go_mod or nil,
	}
end

local node_lsp_servers = {
	"ts_ls",
	"pyright",
	"jsonls",
	"yamlls",
	"html",
	"cssls",
}

local rust_lsp_servers = {
	"rust_analyzer",
}

local go_lsp_servers = {
	"gopls",
}

local always_on_lsp_servers = {
	"lua_ls",
	"taplo",
	"marksman",
}

local server_executables = {
	lua_ls = "lua-language-server",
	ts_ls = "typescript-language-server",
	pyright = "pyright-langserver",
	jsonls = "vscode-json-language-server",
	yamlls = "yaml-language-server",
	taplo = "taplo",
	marksman = "marksman",
	html = "vscode-html-language-server",
	cssls = "vscode-css-language-server",
	rust_analyzer = "rust-analyzer",
	gopls = "gopls",
}

function M.ensure_installed_servers()
	local servers = vim.deepcopy(always_on_lsp_servers)

	if has_executable("node") and has_executable("npm") then
		vim.list_extend(servers, node_lsp_servers)
	end

	if has_executable("cargo") or has_executable("rust-analyzer") then
		vim.list_extend(servers, rust_lsp_servers)
	end

	if has_executable("go") then
		vim.list_extend(servers, go_lsp_servers)
	end

	return servers
end

function M.setup()
	local capabilities = require("blink.cmp").get_lsp_capabilities()

	vim.lsp.config("lua_ls", {
		capabilities = capabilities,
		settings = {
			Lua = {
				diagnostics = { globals = { "vim" } },
			},
		},
	})

	vim.lsp.config("ts_ls", {
		capabilities = capabilities,
		root_markers = node_root_markers,
		on_new_config = function(config, root_dir)
			M.apply_node_workspace(config, root_dir, { tsdk = true })
		end,
	})

	vim.lsp.config("pyright", {
		capabilities = capabilities,
		root_markers = python_root_markers,
		on_new_config = function(config, root_dir)
			M.apply_python_workspace(config, root_dir)
		end,
		settings = {
			python = {
				analysis = {
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
				},
			},
		},
	})

	vim.lsp.config("jsonls", {
		capabilities = capabilities,
		on_new_config = function(config, root_dir)
			M.apply_node_workspace(config, root_dir)
		end,
		settings = {
			json = {
				schemas = require("schemastore").json.schemas(),
				validate = { enable = true },
			},
		},
	})

	vim.lsp.config("yamlls", {
		capabilities = capabilities,
		on_new_config = function(config, root_dir)
			M.apply_node_workspace(config, root_dir)
		end,
		settings = {
			yaml = {
				schemas = {
					["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
					["https://json.schemastore.org/docker-compose.yml"] = "docker-compose*.yml",
				},
			},
		},
	})

	vim.lsp.config("taplo", { capabilities = capabilities })
	vim.lsp.config("marksman", { capabilities = capabilities })
	vim.lsp.config("html", {
		capabilities = capabilities,
		on_new_config = function(config, root_dir)
			M.apply_node_workspace(config, root_dir)
		end,
	})
	vim.lsp.config("cssls", {
		capabilities = capabilities,
		on_new_config = function(config, root_dir)
			M.apply_node_workspace(config, root_dir)
		end,
	})
	vim.lsp.config("rust_analyzer", {
		capabilities = capabilities,
		root_markers = rust_root_markers,
		settings = {
			["rust-analyzer"] = {
				cargo = {
					allFeatures = true,
				},
				checkOnSave = {
					command = "clippy",
				},
			},
		},
	})
	vim.lsp.config("gopls", {
		capabilities = capabilities,
		root_markers = go_root_markers,
		settings = {
			gopls = {
				gofumpt = true,
				staticcheck = true,
				analyses = {
					unusedparams = true,
				},
			},
		},
	})

	for server, executable in pairs(server_executables) do
		if has_executable(executable) then
			vim.lsp.enable(server)
		end
	end
end

return M
