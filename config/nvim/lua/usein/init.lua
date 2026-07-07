require("usein.options")
require("usein.keymaps")
require("usein.theme")

--  Add Yank Highlighting
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight yanked text briefly",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

