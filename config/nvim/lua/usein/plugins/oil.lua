return {
    {
        "benomahony/oil-git.nvim",
        dependencies = { "stevearc/oil.nvim" },
    },
    {
        'stevearc/oil.nvim',
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {
            keymaps = {
                ["<C-c>"] = false,
                ["<C-h>"] = false,
                ["<C-l>"] = false,
                ["_"] = false,
            },
            view_options = {
                show_hidden = true,
            },
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
        lazy = false,
    },
}
