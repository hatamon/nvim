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

--- :h mason-lspconfig-automatic-server-setup
--- したら出てきた設定。
--- これをやれば、いちいち lsp を指定しなくてもセットアップしてくれる模様。
require("mason-lspconfig").setup_handlers {
    function (server_name)
        require("lspconfig")[server_name].setup {}
    end,
}

--- これも none-ls.nvim の公式の設定のまま。
--- formatting だけ prettier に変更した。
--- 公式で null_ls.builtins.formatting.eslint って書いてるところもあったが、
--- require("none-ls.diagnostics.eslint") でよさそう。
--- ただし mason-null-ls.lua で depencencies に "nvimtools/none-ls-extras.nvim" を
--- 追加しておかないとエラーになる。
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.completion.spell,
        require("none-ls.diagnostics.eslint"),
    },
})

----
---- tokyonight.nvim / colorschema
----
vim.cmd[[colorscheme tokyonight]]

----
---- nvim-tree.nvim / filer
----
require("nvim-tree").setup({
  view = {
    width = 30,
  },
})

----
---- lspsaga.nvim / ui
----
vim.keymap.set("n", "<C-K><C-I>",  "<cmd>Lspsaga hover_doc<CR>")
vim.keymap.set('n', '<C-K><C-F>', '<cmd>Lspsaga finder<CR>')
vim.keymap.set("n", "<C-K><C-D>", "<cmd>Lspsaga peek_definition<CR>")
vim.keymap.set("n", "<C-.>", "<cmd>Lspsaga code_action<CR>")
vim.keymap.set("n", "<F2>", "<cmd>Lspsaga rename<CR>")
vim.keymap.set("n", "ge", "<cmd>Lspsaga show_line_diagnostics<CR>")
vim.keymap.set("n", "<C-N>", "<cmd>Lspsaga diagnostic_jump_next<CR>")
vim.keymap.set("n", "<C-P>", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
vim.keymap.set("n", "<F12>", "<cmd>Lspsaga goto_definition<CR>")

----
---- nvim-cmp / completion
----
local cmp = require'cmp'

cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
			-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
			-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
			-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
			-- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		-- documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' }, -- For vsnip users.
		-- { name = 'luasnip' }, -- For luasnip users.
		-- { name = 'ultisnips' }, -- For ultisnips users.
		-- { name = 'snippy' }, -- For snippy users.
	}, {
		{ name = 'buffer' },
	})
})

--  -- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
--  -- Set configuration for specific filetype.
--  --[[ cmp.setup.filetype('gitcommit', {
--    sources = cmp.config.sources({
--      { name = 'git' },
--    }, {
--      { name = 'buffer' },
--    })
-- })
-- require("cmp_git").setup() ]]-- 
--
--  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
--  cmp.setup.cmdline({ '/', '?' }, {
--    mapping = cmp.mapping.preset.cmdline(),
--    sources = {
--      { name = 'buffer' }
--    }
--  })
--
--  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
--  cmp.setup.cmdline(':', {
--    mapping = cmp.mapping.preset.cmdline(),
--    sources = cmp.config.sources({
--      { name = 'path' }
--    }, {
--      { name = 'cmdline' }
--    }),
--    matching = { disallow_symbol_nonprefix_matching = false }
--  })
--
--  -- Set up lspconfig.
--  local capabilities = require('cmp_nvim_lsp').default_capabilities()
--  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
--  require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
--    capabilities = capabilities
--  }
