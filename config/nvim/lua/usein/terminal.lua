local set = vim.keymap.set
-- terminal
set("n", "<leader>t", function()
    vim.cmd.new()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 12)
    vim.cmd.term()
    vim.cmd("startinsert")
end, { desc = "Open Terminal" })

-- set("t", "<esc><esc>", "<c-\\><c-n>")
set("t", "<c-x>", "<c-\\><c-n>")

vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup('custom-term', { clear = true }),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.wo.winfixheight = true;
        vim.bo.filetype = "terminal"
    end
})
