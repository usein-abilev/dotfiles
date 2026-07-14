return {
    "nvim-telescope/telescope.nvim",
    tag = "v0.2.1",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
        local telescope = require("telescope")
        telescope.setup({
            defaults = {
                file_ignore_patterns = {
                    "node_modules",
                    ".git/",
                },
            },
            pickers = {
                find_files = {
                    hidden = true,
                }
            }
        })
        telescope.load_extension("fzf")

        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
        vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Help Tags" })
        vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Live grep" })
        vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Find buffers" })
        vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Grep word" })
        vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
    end,
}
