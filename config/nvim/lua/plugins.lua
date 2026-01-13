return {
    -- Theme 
    { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },

    {
        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
        },
        keys = {
            { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
            { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
            { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
            { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
        },
    },

    { "mg979/vim-visual-multi" },

    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp"
    },

    -- Telescope 
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { "nvim-telescope/telescope.nvim", tag = "v0.2.1",
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
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
            vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Help Tags" })
            vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Live grep" })
            vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Find buffers" })
            vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Grep text" })
            vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
        end,
    },

    -- LSP + Mason (LSP manager)
    { 
        "neovim/nvim-lspconfig", 
        dependencies = {
            "stevearc/conform.nvim",
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-path",
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
            local confirmCompletion = function (fallback)
                if cmp.visible() then
                    cmp.confirm({ select = true })
                else
                    fallback()
                end
            end, { "i", "s" }
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
                    ["<Tab>"] = cmp.mapping(confirmCompletion),
                    ["<Enter>"] = cmp.mapping(confirmCompletion),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                }),
            })
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            vim.lsp.enable("ts_ls", { capabilities = capabilities })
            vim.lsp.enable("gopls", { capabilities = capaibilities })
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
    },

    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    },

    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
}
