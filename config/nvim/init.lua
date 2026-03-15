vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.showmode = true
vim.opt.smartindent = true
vim.opt.scrolloff = 8

vim.opt.laststatus = 2
vim.opt.statusline = "%{toupper(mode())} | %f %y %m %= %l:%c [%p%%]"
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.g.omni_sql_no_default_maps = 1

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath 
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup("plugins")

if vim.fn.has('wsl') == 1 then
    vim.g.clipboard = {
        name = 'WslClipboard',
        copy = {
            ['+'] = 'clip.exe',
            ['*'] = 'clip.exe',
        },
        paste = {
            ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        },
        cache_enabled = 0,
    }
end

-- Configure nvim-treesitter
require"nvim-treesitter".install { "lua", "javascript", "typescript", "c", "go" }
vim.api.nvim_create_autocmd('FileType', {
  pattern = { '<filetype>' },
  callback = function() vim.treesitter.start() end,
})

require('lualine').setup()
require('telescope').load_extension('fzf')

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set({'n', 'i', 'v'}, '<C-c>', '<Esc>:nohlsearch<CR>', { noremap = true, silent = true })

-- directory view (project view)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move selected lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Bind undotree to space+u
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- Git integration
vim.keymap.set("n", "<leader>gs", vim.cmd.Git);

-- Global LSP attach handler
vim.api.nvim_create_autocmd("LspAttach", { 
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function (_, buffer)
        local opts = { buffer = buffer, silent = true, noremap = true }
        local builtin = require("telescope.builtin")

        vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
        vim.keymap.set("n", "gr", builtin.lsp_references, opts)
        vim.keymap.set("n", "gi", builtin.lsp_implementations, opts)
        vim.keymap.set("n", "gt", builtin.lsp_type_definitions, opts)
        vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, opts)
        vim.keymap.set("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols, opts)

        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
    end,
})

-- Add theme or transparency 
vim.o.background = "dark"
require"gruvbox".setup{
    transparent_mode=true,
    terminal_colors=true,
    contrast="hard",
    bold = false,
    overrides = {
        NormalFloat = { bg = "#282828" },
        FloatBorder = { fg = "#ebdbb2", bg = "#282828" },

        typescriptVariable = { link = "GruvboxRed" },
        typescriptOperator = { link = "GruvboxRed" },
        ["@lsp.type.member.typescript"] = { link = "typescriptMember" }, -- GruvboxAqua
    },
}
vim.cmd([[colorscheme gruvbox]])

-- Customize diagnostic virtual text colors
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#fb4934", bg = "NONE" }) -- red
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn",  { fg = "#fe8019", bg = "NONE" }) -- orange
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo",  { fg = "#83a598", bg = "NONE" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint",  { fg = "#b8bb26", bg = "NONE" })
vim.api.nvim_set_hl(0, "Todo", { fg = "#fabd2f", bg = "none", bold = true })
