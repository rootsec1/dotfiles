-- rootsec1 preferences --

-- Basic settings
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set wrap")
vim.cmd("set number")
vim.cmd("set ruler")
vim.cmd("set encoding=utf-8")
vim.cmd("set ttyfast")
vim.cmd("set cursorline")
vim.cmd("set cursorlineopt=line")
vim.cmd("set scrolloff=5")
vim.cmd("set clipboard=unnamedplus")
vim.cmd("set fixendofline")

-- Set leader key
vim.g.mapleader = " "

-- Enable Lua loader (Neovim 0.9+)
if vim.loader and vim.loader.enable then
    vim.loader.enable()
end

-- If using neovide, disable weird cursor VFX
if vim.g.neovide then
    vim.g.neovide_cursor_animation_length = 0
    vim.g.neovide_cursor_trail_size = 0
    vim.g.neovide_cursor_vfx_mode = ""
    vim.g.neovide_scroll_animation_length = 0.05
    vim.g.neovide_fullscreen = true
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from lua/plugins.lua
require("lazy").setup("plugins")

-- Theme setup
vim.g.gruvbox_material_background = "medium"
vim.g.gruvbox_material_better_performance = 1

-- Apply colorscheme
vim.cmd("colorscheme gruvbox-material")

-- Override cursorline to show as underline
vim.cmd("highlight CursorLine cterm=underline gui=underline ctermbg=NONE guibg=NONE")

-- Plugin configurations

-- Telescope setup
local telescope = require("telescope")
telescope.setup()
telescope.load_extension("fzf")
telescope.load_extension("ui-select")

-- Treesitter setup
local treesitterConfig = require("nvim-treesitter.configs")
treesitterConfig.setup({
    ensure_installed = {
        "lua", "javascript", "typescript", "python", "json", "yaml",
        "markdown", "markdown_inline", "toml", "html", "css", "bash",
        "dockerfile", "gitignore", "vim", "vimdoc"
    },
    highlight = { enable = true },
    indent = { enable = true }
})

-- Lualine setup
require("lualine").setup({
    options = {
        icons_enabled = true,
        theme = "gruvbox-material"
    },
    sections = {
        lualine_b = { "branch", "diff", {
            "diagnostics",
            sources = { "nvim_lsp" },
        } },
        lualine_c = { {
            "filename",
            file_status = true, -- Shows [+] for modified files
            path = 1,           -- Show relative path
        } },
    }
})

-- Neotree setup
require("neo-tree").setup({
    close_if_last_window = true,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    window = {
        position = "left",
        width = 35,
    },
    filesystem = {
        follow_current_file = {
            enabled = true,
        },
    },
})

-- Auto-pairs setup
require("nvim-autopairs").setup()

-- Indent guides setup
require("ibl").setup()

-- Styled tabs
require("bufferline").setup({
    options = {
        mode = "tabs",
        separator_style = "thick", -- or "slant", "padded_slant", "slope"
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        color_icons = true,
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        offsets = {
            {
                filetype = "neo-tree",
                text = "File Explorer",
                text_align = "center",
                separator = true
            }
        },
        custom_areas = {
            right = function()
                local result = {}
                local seve = vim.diagnostic.severity
                local error = #vim.diagnostic.get(0, { severity = seve.ERROR })
                local warning = #vim.diagnostic.get(0, { severity = seve.WARN })

                if error ~= 0 then
                    table.insert(result, { text = "  " .. error, fg = "#EC5241" })
                end
                if warning ~= 0 then
                    table.insert(result, { text = "  " .. warning, fg = "#EFB839" })
                end
                return result
            end,
        }
    },
    highlights = {
        buffer_selected = {
            bold = true,
            italic = false,
        },
        tab_selected = {
            bold = true,
        }
    }
})

-- UI input beautify
require("dressing").setup()

-- Colorize color codes
require("colorizer").setup()

require("Comment").setup({
    padding = true,
    sticky = true,
    ignore = "^$",
    toggler = {
        line = "gcc",
        block = "gbc",
    },
    opleader = {
        line = "gc",
        block = "gb",
    },
    extra = {
        above = "gcO",
        below = "gco",
        eol = "gcA",
    },
    mappings = {
        basic = true,
        extra = true,
    },
})

-- Trouble setup
require("trouble").setup({
    action_keys = {
        open_tab = "t",
        open = "<cr>"
    }
})

-- LSP hover and signature help
require("lsp_signature").setup({
    bind = true,
    handler_opts = {
        border = "rounded"
    },
    floating_window = true,
    hint_enable = true,
    hint_prefix = "🐼 ",
})

-- Cmdline setup
require("fine-cmdline").setup({
    cmdline = {
        prompt = "🐲 ❯❯❯ "
    },
    popup = {
        position = {
            row = "50%", -- Center vertically
            col = "50%", -- Center horizontally
        },
        size = {
            width = "60%",
        },
        border = {
            style = "rounded",
        },
        win_options = {
            winhighlight = "Normal:Normal,FloatBorder:Special",
        }
    }
})

-- AI assistant
require("codecompanion").setup({
    adapters = {
        http = {
            openai = function()
                return require("codecompanion.adapters").extend("openai", {
                    env = {
                        api_key = os.getenv("OPENAI_API_KEY"),
                        model = "o4-mini-high"
                    },
                })
            end,
        },
    },
    strategies = {
        chat = {
            adapter = "openai",
            keymaps = {
                accept_change = {
                    modes = { n = "y", v = "y" },
                    description = "Accept the suggested change",
                },
                reject_change = {
                    modes = { n = "n", v = "n" },
                    opts = { nowait = true },
                    description = "Reject the suggested change",
                },
            },

        },
        inline = {
            adapter = "openai",
            keymaps = {
                accept_change = {
                    modes = { n = "y", v = "y" },
                    description = "Accept the suggested change",
                },
                reject_change = {
                    modes = { n = "n", v = "n" },
                    opts = { nowait = true },
                    description = "Reject the suggested change",
                },
            },
        },
    },
    display = {
        chat = {
            window = {
                layout = "vertical",
                width = 0.3,
                position = "right",
            },
        },
    }
})

-- Notifications
vim.notify = require("notify")

-- LSP and completion setup

-- Mason setup
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls",
        "ts_ls",
        "pyright",
        "jsonls",
        "yamlls",
        "taplo",
        "marksman",
        "html",
        "cssls"
    },
    automatic_installation = true,
})

-- Auto-completion setup
local cmp = require("cmp")
cmp.setup({
    mapping = {
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    },
    sources = { { name = "nvim_lsp" } }
})

-- LSP configuration
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("lua_ls", {
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } }
        }
    }
})

vim.lsp.config("ts_ls", {
    capabilities = capabilities
})

vim.lsp.config("pyright", {
    capabilities = capabilities,
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
            }
        }
    }
})

-- JSON
vim.lsp.config("jsonls", {
    capabilities = capabilities,
    settings = {
        json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
        }
    }
})

-- YAML
vim.lsp.config("yamlls", {
    capabilities = capabilities,
    settings = {
        yaml = {
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://json.schemastore.org/docker-compose.yml"] = "docker-compose*.yml"
            }
        }
    }
})

-- TOML
vim.lsp.config("taplo", { capabilities = capabilities })

-- Markdown
vim.lsp.config("marksman", { capabilities = capabilities })

-- HTML
vim.lsp.config("html", { capabilities = capabilities })

-- CSS
vim.lsp.config("cssls", { capabilities = capabilities })

-- Enable LSP servers
vim.lsp.enable("lua_ls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("pyright")
vim.lsp.enable("jsonls")
vim.lsp.enable("yamlls")
vim.lsp.enable("taplo")
vim.lsp.enable("marksman")
vim.lsp.enable("html")
vim.lsp.enable("cssls")

-- Autocommands

-- Enable spell checking
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }

-- Better search behavior
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false

-- Better splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Redcuce glitch during scroll
vim.opt.lazyredraw = true

-- Auto-open Neotree on startup and keep it open
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.cmd("Neotree filesystem reveal left")
        -- If a file was opened, focus on the editor
        if vim.fn.argc() > 0 then
            vim.cmd("wincmd l")
        end
    end,
})

-- Auto-format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

-- Keymaps

-- File operations
vim.keymap.set("n", "<C-p>", function()
    require("telescope.builtin").find_files({
        attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local selection = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                vim.cmd("tabnew " .. selection.path)
                -- Ensure Neotree is visible after opening file
                vim.cmd("Neotree show left")
            end)
            return true
        end
    })
end, { desc = "Find files in new tab" })

vim.keymap.set("n", "<C-f>", function()
    require("telescope.builtin").current_buffer_fuzzy_find()
end, { desc = "Search in current file" })

vim.keymap.set("n", "<leader>f", require("telescope.builtin").live_grep, { desc = "Search in all files" })

-- Formatting
vim.keymap.set("n", "<C-k>", function()
    vim.lsp.buf.format({ async = true })
end, { desc = "Format file" })

-- Tab management
vim.keymap.set("n", "<S-Tab>", ":tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<C-w>", ":tabclose<CR>", { desc = "Close tab" })

-- UI toggles
vim.keymap.set("n", "<C-b>", ":Neotree toggle<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>g", ":LazyGit<CR>", { desc = "Open LazyGit" })

-- Vanilla VIM shortcuts
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = false })
vim.api.nvim_set_keymap("v", "jj", "<Esc>", { noremap = false })

-- VS Code-like shortcuts
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save file" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>", { desc = "Save file (insert mode)" })
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })
vim.keymap.set("n", "<C-z>", "u", { desc = "Undo" })
vim.keymap.set("n", "<C-y>", "<C-r>", { desc = "Redo" })
vim.keymap.set("n", "<C-d>", "yyp", { desc = "Duplicate line" })
vim.keymap.set("n", "<leader>/", "gcc", { desc = "Toggle line comment", remap = true })
vim.keymap.set("v", "<leader>/", "gc", { desc = "Toggle comment selection", remap = true })

-- GoTo definitions
vim.keymap.set("n", "<C-g>", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "<C-u>", ":Trouble lsp_references toggle focus=true<CR>", { desc = "Toggle usages" })
vim.keymap.set("n", "<C-i>", vim.lsp.buf.hover, { desc = "Show info" })

-- Copy/Cut/Paste - explicitly use system clipboard
vim.keymap.set("n", "<C-x>", '"+dd', { desc = "Cut line" })
vim.keymap.set("n", "<C-c>", '"+yy', { desc = "Copy line" })
vim.keymap.set("n", "<C-v>", '"+p', { desc = "Paste" })

-- Copy/Cut for visual selections
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy selection" })
vim.keymap.set("v", "<C-x>", '"+d', { desc = "Cut selection" })

-- Paste in insert mode
vim.keymap.set("i", "<C-v>", "<C-r>+", { desc = "Paste in insert mode" })

-- CmdLine
vim.keymap.set("n", ":", ":FineCmdline<CR>", { desc = "Enhanced command line" })

-- Find and replace
vim.keymap.set("n", "<C-h>", ":%s//gc<Left><Left><Left>", { desc = "Find and replace" })

-- Quit all tabs and close Neovim entirely (like Cmd+Q in VS Code)
vim.keymap.set("n", "<leader>q", ":qa!<CR>", { desc = "Quit all and exit Neovim" })

-- View error from LSP
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show error details" })

-- AI autocomplete shortcuts
vim.keymap.set("n", "<C-l>", ":CodeCompanion<CR>", { desc = "CodeCompanion inline command" })
vim.keymap.set("v", "<C-l>", ":CodeCompanion<CR>", { desc = "CodeCompanion inline with selection" })
vim.keymap.set("n", "<leader>l", ":CodeCompanionActions<CR>", { desc = "CodeCompanion inline suggestions" })
vim.keymap.set("v", "<leader>l", ":CodeCompanionActions<CR>", { desc = "CodeCompanion inline with selection" })

-- Navigate highlighted references
vim.keymap.set("n", "]]", require("illuminate").goto_next_reference, { desc = "Next reference" })
vim.keymap.set("n", "[[", require("illuminate").goto_prev_reference, { desc = "Previous reference" })
