local set = vim.keymap.set

set('n', '<Esc>', '<cmd>nohlsearch<CR>')
set({'n', 'i', 'v'}, '<C-c>', '<Esc>:nohlsearch<CR>', { noremap = true, silent = true })

-- directory view (project view)
-- set("n", "<leader>pv", vim.cmd.Ex)
set("n", "<leader>pv", "<cmd>Oil<CR>")

-- Move selected lines up/down
set("v", "J", ":m '>+1<CR>gv=gv")
set("v", "K", ":m '<-2<CR>gv=gv")

-- Resize windows
set("n", "<M-,>", "<c-w>5<")
set("n", "<M-.>", "<c-w>5>")
set("n", "<M-=>", "<c-w>5+")
set("n", "<M-->", "<c-w>5-")

-- Bind undotree to space+u
set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- Git integration
set("n", "<leader>gs", vim.cmd.Git);

-- Global LSP attach handler
vim.api.nvim_create_autocmd("LspAttach", { 
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function (_, buffer)
        local opts = { buffer = buffer, silent = true, noremap = true }
        local builtin = require("telescope.builtin")

        set("n", "gd", builtin.lsp_definitions, opts)
        set("n", "gr", builtin.lsp_references, opts)
        set("n", "gi", builtin.lsp_implementations, opts)
        set("n", "gt", builtin.lsp_type_definitions, opts)
        set("n", "<leader>ds", builtin.lsp_document_symbols, opts)
        set("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols, opts)

        set("n", "K", vim.lsp.buf.hover, opts)
        set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        set("n", "<leader>vd", vim.diagnostic.open_float, opts)
        set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
    end,
})

-- terminal
set("n", "<leader>t", function()
    vim.cmd.new()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 12)
end, { desc = "Open Terminal" })

set("t", "<esc><esc>", "<c-\\><c-n>")

vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup('custom-term', { clear = true }),
    callback = function() 
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.wo.winfixheight = true;
        vim.bo.filetype = "terminal"
    end
})

