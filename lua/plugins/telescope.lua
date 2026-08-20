return {
	'nvim-telescope/telescope.nvim',
	version = '*',
	dependencies = {
		'nvim-lua/plenary.nvim',
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
	},

	-- SEMUA KONFIGURASI TELESCOPE HARUS DI DALAM TABEL OPTS INI
	opts = {
		defaults = {
			layout_strategy = "horizontal",
			layout_config = {
				width = 0.70, -- Memperbesar total jendela agar perubahan lebih terasa
				horizontal = {
					preview_width = 0.65, -- Preview mengambil 65% lebar jendela
				},
			},
		},
	},

	config = function(_, opts)
		-- Memanggil setup dan memasukkan tabel opts di atas otomatis
		require('telescope').setup(opts)
		pcall(require('telescope').load_extension, 'fzf')

		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
		vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
		vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
		vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
	end
}
