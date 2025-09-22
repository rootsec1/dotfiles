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
require("catppuccin").setup({
    flavour = "mocha",
    transparent_background = true,
    integrations = {
        telescope = true,
        neo_tree = true,
        treesitter = true,
        gitsigns = true,
        mason = true,
        cmp = true,
        native_lsp = {
            enabled = true,
        },
    }
})

-- Apply colorscheme
vim.cmd.colorscheme("catppuccin")

-- Override cursorline to show as underline
vim.cmd("highlight CursorLine cterm=underline gui=underline ctermbg=NONE guibg=NONE")

-- Plugin configurations

-- Telescope setup
local telescope = require("telescope")
telescope.setup({
    defaults = {
        theme = "catppuccin",
    }
})
telescope.load_extension("fzf")

-- Treesitter setup
local treesitterConfig = require("nvim-treesitter.configs")
treesitterConfig.setup({
    ensure_installed = { "lua", "javascript", "python" },
    highlight = { enable = true },
    indent = { enable = true }
})

-- Lualine setup
require("lualine").setup({
    options = {
        icons_enabled = true,
        theme = "dracula"
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
        width = 45,
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
        separator_style = "slant",
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        color_icons = true,
        diagnostics = "nvim_lsp",
    }
})

-- LSP and completion setup

-- Mason setup
require("mason").setup()
require("mason-lspconfig").setup()

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

-- Enable LSP servers
vim.lsp.enable("lua_ls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("pyright")

-- Autocommands

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

-- Auto-save on focus lost or buffer leave
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
    callback = function()
        if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
            vim.cmd("silent! write")
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

vim.keymap.set("n", "<leader>F", require("telescope.builtin").live_grep, { desc = "Search in all files" })

-- Formatting
vim.keymap.set("n", "<C-k>", function()
    vim.lsp.buf.format({ async = true })
end, { desc = "Format file" })

-- Tab management
vim.keymap.set("n", "<S-Tab>", ":tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<C-w>", ":tabclose<CR>", { desc = "Close tab" })

-- UI toggles
vim.keymap.set("n", "<C-b>", ":Neotree filesystem reveal left<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>g", ":LazyGit<CR>", { desc = "Open LazyGit" })

-- VS Code-like shortcuts
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save file" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>", { desc = "Save file (insert mode)" })
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })
vim.keymap.set("n", "<C-z>", "u", { desc = "Undo" })
vim.keymap.set("n", "<C-y>", "<C-r>", { desc = "Redo" })
vim.keymap.set("n", "<C-d>", "yyp", { desc = "Duplicate line" })

-- Copy/Cut/Paste - explicitly use system clipboard
vim.keymap.set("n", "<C-x>", '"+dd', { desc = "Cut line" })
vim.keymap.set("n", "<C-c>", '"+yy', { desc = "Copy line" })
vim.keymap.set("n", "<C-v>", '"+p', { desc = "Paste" })

-- Copy/Cut for visual selections
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy selection" })
vim.keymap.set("v", "<C-x>", '"+d', { desc = "Cut selection" })

-- Paste in insert mode
vim.keymap.set("i", "<C-v>", "<C-r>+", { desc = "Paste in insert mode" })

-- Find and replace
vim.keymap.set("n", "<C-h>", ":%s//gc<Left><Left><Left>", { desc = "Find and replace" })

-- Quit all tabs and close Neovim entirely (like Cmd+Q in VS Code)
vim.keymap.set("n", "<leader>q", ":qa<CR>", { desc = "Quit all and exit Neovim" })

-- View error from LSP
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show error details" })
