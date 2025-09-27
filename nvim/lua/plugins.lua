return {
    {
        "scottmckendry/cyberdream.nvim",
        lazy = false,
        priority = 1000,
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }
        }
    },
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        lazy = false,
        build = ":TSUpdate"
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        lazy = false
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" }
    },
    {
        "kdheepak/lazygit.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
    },
    {
        "RRethy/vim-illuminate",
        event = { "BufReadPost", "BufNewFile" }
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl"
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" }
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",       -- Buffer completions
            "hrsh7th/cmp-path",         -- Path completions
            "hrsh7th/cmp-cmdline",      -- Command line completions
            "L3MON4D3/LuaSnip",         -- Snippet engine
            "saadparwaiz1/cmp_luasnip", -- Snippet completions
            "onsails/lspkind.nvim",     -- VS Code-like icons
        }
    },
    {
        "lewis6991/gitsigns.nvim"
    },
    {
        "akinsho/bufferline.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
    },
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
        }
    },
    {
        "numToStr/Comment.nvim",
    },
    {
        "VonHeikemen/fine-cmdline.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
    },
    {
        "ray-x/lsp_signature.nvim",
        event = "VeryLazy",
    },
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
    },
    {
        "rcarriga/nvim-notify"
    },
    {
        "stevearc/dressing.nvim"
    },
    {
        "HiPhish/rainbow-delimiters.nvim"
    },
    {
        "NvChad/nvim-colorizer.lua"
    },
    {
        "b0o/schemastore.nvim",
        ft = { "json", "yaml" }
    }
}
