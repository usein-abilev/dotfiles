return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    init = function()
        local parsers = {
            "vim",
            "json",
            "javascript",
            "typescript",
            "gitignore",
            "svelte",
            "html",
            "css",
            "lua",
            "c",
            "go"
        };

        local treesitter_group = vim.api.nvim_create_augroup("UseinTreesitter", { clear = true })

        vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
            group = treesitter_group,
            callback = function()
                if vim.bo.buftype ~= "" then
                    return
                end
                pcall(vim.treesitter.start, 0)
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            group = treesitter_group,
            once = true,
            callback = function()
                require("nvim-treesitter").install(parsers)
            end,
        })
    end,
}
