return {
    {	"williamboman/mason.nvim" },
	  { "williamboman/mason-lspconfig.nvim" },
	  { "neovim/nvim-lspconfig" },
    { 'nvim-treesitter/nvim-treesitter' },
    { 'nvim-tree/nvim-tree.lua' },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true,
    },
	-- Vscode-like pictograms
	{
		"onsails/lspkind.nvim",
		event = { "VimEnter" },
	},
	-- Auto-completion engine
	{
		"hrsh7th/nvim-cmp",
	},
	-- Code snippet engine
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
	},
}
