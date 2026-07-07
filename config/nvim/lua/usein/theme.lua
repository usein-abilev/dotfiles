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
