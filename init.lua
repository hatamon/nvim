vim.g.mapleader = " "
vim.keymap.set("n", "Y", "yy")
vim.keymap.set("n", "<C-PageDown>", "<cmd>bn<CR>", { silent = true })
vim.keymap.set("n", "<C-PageUp>", "<cmd>bp<CR>", { silent = true })
vim.keymap.set("n", "<A-F>", "<cmd>lua vim.lsp.buf.format()<CR>", { silent = true })
vim.keymap.set("t", "<C-V>*", "`git branch --show-current`")
vim.keymap.set("t", "<ESC>", "<C-\\><C-n>")

----
---- disable netrw at the very start of your init.lua
----
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

----
---- disable diagnostics hide virtual text
----
--- mason でインストールした eslint-lsp により eslint が有効になるが、
--- エラーがコード中に表示されてしまい結構うざい。
--- エラーは lspsaga により表示したいので、この設定でコード中のエラー表示をなくす。
vim.diagnostic.config({
    virtual_text = false,
})

----
---- set vim options
----
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.updatetime = 500
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.eol = true
vim.opt.fixeol = true
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.smartindent = true
vim.opt.signcolumn = 'yes'

----
---- lazy.nvim / package manager
----
--- :Lazy
--- でプラグインの管理をできる。
--- この init.lua と、lua/plugins があれば勝手にインストールしてくれる．
--- 以下は公式のインストール方法そのまま
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

----
---- nvim-cmp / completion
----
local cmp = require 'cmp'

cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
    }, {
        { name = "buffer" },
    })
})

----
---- mason.nvim / lsp
----
--- :Mason
--- で lsp の管理ができる。
--- 以下をインストールすればいい。
--- * eslint-lsp eslint
--- * omnisharp
--- * prettier
--- * typescript-language-server tsserver
require("mason").setup()
require("mason-lspconfig").setup()
require("mason-null-ls").setup({
    automatic_setup = true,
    handlers = {},
})

--- :h mason-lspconfig-automatic-server-setup
--- したら出てきた設定。
--- これをやれば、いちいち lsp を指定しなくてもセットアップしてくれる模様。
require("mason-lspconfig").setup_handlers {
    function(server_name)
        require("lspconfig")[server_name].setup {
            -- これがないと .eslintrc.js が実行されるパスが、ソースコードのパスになってしまう
            -- これをいれれば、.eslintrc.js が存在するパスで実行される
            -- https://www.reddit.com/r/neovim/comments/1d0757g/comment/l5qu6us/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
            on_init = function(client)
                client.config.settings.workingDirectory = {
                    directory = client.config.root_dir
                }
            end,
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
        }
    end,
    tsserver = function()
      require("lspconfig").tsserver.setup({
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      })
    end,
}

-- lspの設定後に追加
vim.opt.completeopt = "menu,menuone,noselect"

--- これも none-ls.nvim の公式の設定のまま。
--- formatting だけ prettierd に変更した。
---   prettier だと neovim 終了時に crash するみたいなので、prettierd にしてみた。
--- 公式で null_ls.builtins.formatting.eslint って書いてるところもあったが、
--- require("none-ls.diagnostics.eslint") でよさそう。
--- ただし mason-null-ls.lua で depencencies に "nvimtools/none-ls-extras.nvim" を
--- 追加しておかないとエラーになる。
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.prettierd,
        null_ls.builtins.completion.spell,
        require("none-ls.diagnostics.eslint"),
    },
})

----
---- tokyonight.nvim / colorschema
----
vim.cmd [[colorscheme tokyonight]]

----
---- nvim-tree.nvim / filer
----
require("nvim-tree").setup({
    view = {
        width = 30,
    },
})
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeOpen<CR>", { silent = true })

----
---- lspsaga.nvim / ui
----
vim.keymap.set("n", "<C-K><C-I>", "<cmd>Lspsaga hover_doc<CR>")
vim.keymap.set('n', '<C-K><C-F>', '<cmd>Lspsaga finder<CR>')
vim.keymap.set("n", "<C-K><C-D>", "<cmd>Lspsaga peek_definition<CR>")
vim.keymap.set("n", "<C-.>", "<cmd>Lspsaga code_action<CR>")
vim.keymap.set("n", "<F2>", "<cmd>Lspsaga rename<CR>")
vim.keymap.set("n", "ge", "<cmd>Lspsaga show_line_diagnostics<CR>")
vim.keymap.set("n", "<C-N>", "<cmd>Lspsaga diagnostic_jump_next<CR>")
vim.keymap.set("n", "<C-P>", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
vim.keymap.set("n", "<F12>", "<cmd>Lspsaga goto_definition<CR>")

----
---- bufferline / ui
----
vim.opt.termguicolors = true
require("bufferline").setup {
    options = {
        indicator = {
            style = 'underline',
        },
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
        end
    }
}

----
---- scrollbar / ui
----
require("scrollbar").setup()

----
---- lualine / ui
----
require('lualine').setup()

----
---- indent-blankline / ui
----
require("ibl").setup()

----
---- telescope / search
----
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

require('telescope').load_extension('project')

----
---- toggleterm / ui
----
require'toggleterm'.setup({
    open_mapping = '<C-\\>',
    start_in_insert = true,
    direction = 'float',
})
vim.cmd [[let &shell = '"C:/Program Files/Git/bin/bash.exe"']]
vim.cmd [[let &shellcmdflag = '-s']]

----
---- gitsigns / git
----
require('gitsigns').setup {
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true
  },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  current_line_blame_formatter_opts = {
    relative_time = false,
  },
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
}
