-- Install plugins
return {
    { 'rust-lang/rust.vim' },
    {
        'mrcjkb/rustaceanvim',
        version = '^4',
        ft = { 'rust' },
    },
    { 'nvim-tree/nvim-tree.lua' },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true,
    },
}
