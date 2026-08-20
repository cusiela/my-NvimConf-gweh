-- ~/.config/nvim/lua/plugins/nvim-tree.lua

return {
	{
		'echasnovski/mini.icons',
		version = false,
		config = function()
			require('mini.icons').setup()
		end,
	},
	{
		'nvim-tree/nvim-tree.lua',
		dependencies = { 'echasnovski/mini.icons' },
		config = function()
			vim.g.loaded_netrw       = 1
			vim.g.loaded_netrwPlugin = 1

			local api                = require('nvim-tree.api')

			require('nvim-tree').setup({
				disable_netrw      = true,
				hijack_directories = { enable = false, auto_open = false },
				view               = { width = 30, side = 'left' },
				renderer           = {
					indent_markers = { enable = false },
					icons = {
						show = { file = true, folder = true, folder_arrow = true, git = false },
						glyphs = { folder = { arrow_closed = '▶', arrow_open = '▼' } },
					},
				},
				git                = { enable = false },
				diagnostics        = { enable = false },
				filters            = { dotfiles = false },
			})

			vim.keymap.set('n', '<leader>e', function()
				api.tree.toggle({ find_file = true, focus = true })
			end, { desc = 'Nvim-tree: toggle (sorot file)' })

			vim.keymap.set('n', '<leader>b', function()
				api.tree.toggle({ find_file = false, focus = true })
			end, { desc = 'Nvim-tree: toggle (struktur awal)' })

			-- ==========================================================
			-- Auto-close: tutup nvim-tree HANYA kalau window terakhir yang
			-- berisi FILE KODE ditutup, sehingga tersisa cuma nvim-tree.
			-- Kalau masih ada >1 tab kode, nvim-tree TIDAK ditutup (fokus
			-- pindah ke tab kode lain) -- sesuai permintaan.
			-- ==========================================================
			vim.api.nvim_create_autocmd('QuitPre', {
				group    = vim.api.nvim_create_augroup('custom.nvimtree.autoclose', { clear = true }),
				callback = function()
					-- QuitPre kepicu SEBELUM window benar-benar ditutup, saat
					-- kamu :q sebuah window kode. Kita hitung berapa window
					-- kode biasa yang tersisa SELAIN yang sedang ditutup ini.
					local tree_wins = {}
					local code_wins = {}

					for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
						if vim.api.nvim_win_is_valid(w) then
							local cfg = vim.api.nvim_win_get_config(w)
							if cfg.relative == '' then -- bukan floating popup
								local b  = vim.api.nvim_win_get_buf(w)
								local ft = vim.bo[b].filetype
								if ft == 'NvimTree' then
									table.insert(tree_wins, w)
								else
									table.insert(code_wins, w)
								end
							end
						end
					end

					-- Saat QuitPre, window yang sedang di-:q MASIH terhitung di
					-- code_wins. Jadi kalau code_wins == 1 (cuma yang sedang
					-- ditutup) DAN ada nvim-tree -> setelah ini tinggal
					-- nvim-tree sendirian -> tutup dia juga.
					if #tree_wins > 0 and #code_wins <= 1 then
						api.tree.close()
					end
				end,
			})
		end,
	},
}
