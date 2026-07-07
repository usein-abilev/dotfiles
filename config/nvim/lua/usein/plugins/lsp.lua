return { 
    "neovim/nvim-lspconfig", 
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/nvim-cmp",
    },
    config = function() 
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "ts_ls",
                "gopls",
                "eslint",
            },
        })

        -- Common LSP options
        local cmp = require("cmp")
        cmp.setup({
            snippet = { 
                expand = function (args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-n>"] = cmp.mapping.select_next_item(),
                ["<C-p>"] = cmp.mapping.select_prev_item(),
                ["<Tab>"] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
            }),
        })
        cmp.setup.cmdline({ "?", "/" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer" },
            } 
        });
        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "path" },
                { name = "cmdline", keyword_length = 3 },
            }),
            matching = { disallow_symbol_nonprefix_matching = false },
        })
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        vim.lsp.enable("ts_ls", { capabilities = capabilities })
        vim.lsp.enable("gopls", { capabilities = capabilities })
        vim.lsp.enable("eslint", {
            capabilities = capabilities,
            on_attach = function(client, bufnr)
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = bufnr,
                    command = "EslintFixAll",
                })
            end,
        })

        -- Diagnostics look
        vim.diagnostic.config({
            virtual_text = true,
            virtual_lines = false,
            float = {
                border = "rounded",
                source = "always",
                style = "minimal",
            },
        })

        -- Formatter
        local conform = require("conform");
        conform.setup({
            format_on_save = function(bufnr)
                conform.format({
                    lsp_fallback = true,
                    async=false,
                    timeout_ms = 500,
                });
            end,
            formatters_by_ft = {
                javascript = { "prettier", "eslint_d", stop_after_first = true },
                typescript = { "prettier", "eslint_d", stop_after_first = true },
                go = { "goimports" },
            },
        })
        vim.keymap.set({ "n", "v" }, "<leader>fm", function()
            conform.format({ 
                lsp_fallback = true,
                async=false,
                timeout_ms = 500,
            });
        end, { desc = "Format current file or selection" })
    end,
}
