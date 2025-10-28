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

-- Customize diagnostic virtual text colors
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#fb4934", bg = "NONE" }) -- red
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn",  { fg = "#fe8019", bg = "NONE" }) -- orange
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo",  { fg = "#83a598", bg = "NONE" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint",  { fg = "#b8bb26", bg = "NONE" })

vim.keymap.set({'n', 'i', 'v'}, '<C-c>', '<Esc>:nohlsearch<CR>', { noremap = true, silent = true })

-- directory view (project view)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move selected lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Configure nvim-treesitter
require"nvim-treesitter.configs".setup {
    ensure_installed = { "lua", "javascript", "typescript", "c", "go" },
    highlight = { enable = true },
}
require('lualine').setup()

-- Global LSP attach handler
vim.api.nvim_create_autocmd("LspAttach", { 
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function (_, buffer)
        local opts = { buffer = buffer, silent = true, noremap = true }

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    end,
})

-- Add theme or transparency 
vim.o.background = "dark"
require"gruvbox".setup{
    terminal_colors=true,
    contrast="hard",
    bold = true,
}
vim.cmd([[colorscheme gruvbox]])

-- Make all backgrounds transparent
vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NonText guibg=NONE ctermbg=NONE
  highlight EndOfBuffer guibg=NONE ctermbg=NONE
  highlight LineNr guibg=NONE ctermbg=NONE
  highlight SignColumn guibg=NONE ctermbg=NONE
  highlight Folded guibg=NONE ctermbg=NONE
  highlight FoldColumn guibg=NONE ctermbg=NONE
  highlight CursorLine guibg=NONE ctermbg=NONE
  highlight CursorColumn guibg=NONE ctermbg=NONE
  highlight ColorColumn guibg=NONE ctermbg=NONE
  highlight NormalFloat guibg=NONE ctermbg=NONE
]])

vim.cmd([[
  "highlight CursorLineNr guibg=#3c3836 ctermbg=237
  "highlight Pmenu guibg=#3c3836 ctermbg=237
  "highlight PmenuSel guibg=#504945 ctermbg=239
]])
