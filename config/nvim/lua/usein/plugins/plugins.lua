return {
    {
        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
        },
        keys = {
            { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
            { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
            { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
            { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
        },
    },

    -- Theme
    { "blazkowolf/gruber-darker.nvim" },
    { "ellisonleao/gruvbox.nvim",     priority = 1000, config = true },

    -- { "mg979/vim-visual-multi" }, - why when *cgn. exists

    { "mbbill/undotree" },

    { "tpope/vim-fugitive" },

    {
        "lewis6991/gitsigns.nvim",
        config = function()
            vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
        end,
    },

    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp"
    },

    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {},
    },
}
