return {
    'hrsh7th/nvim-cmp',
    config = function()
        require('cmp').setup({})
    end,
    dependencies = {
        'L3MON4D3/LuaSnip',
        'neovim/nvim-lspconfig',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'saadparwaiz1/cmp_luasnip',
        -- 'hrsh7th/cmp-path',
        -- 'hrsh7th/cmp-cmdline',
	}
}
