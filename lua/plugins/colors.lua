return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			-- transparansi ditangani terpusat di config/transparency.lua
			vim.cmd.colorscheme "tokyonight"
		end
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			theme = 'tokyonight',
		},


	},
}
