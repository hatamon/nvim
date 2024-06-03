return {
	{
    'hrsh7th/nvim-cmp',
    config = function()
        require('cmp').setup({})
    end,
    dependencies = {
				'neovim/nvim-lspconfig',
				'hrsh7th/cmp-nvim-lsp',
				-- 'hrsh7th/cmp-buffer',
				-- 'hrsh7th/cmp-path',
				-- 'hrsh7th/cmp-cmdline',
    }
	}
}
