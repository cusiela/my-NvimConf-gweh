return {
	"mg979/vim-visual-multi",
	init = function()
		-- Mengaktifkan mapping bawaan plugin secara paksa
		vim.g.VM_default_mappings = 1

		-- Opsional: Jika Ctrl + Arrow bawaan tidak bekerja di terminal Anda,
		-- Anda bisa menggantinya ke tombol custom di bawah ini
		vim.g.VM_maps = {
			["Find Under"] = "<C-n>",   -- Meniru Ctrl+d VS Code
			["Add Cursor Down"] = "<C-Down>", -- Tambah kursor ke bawah
			["Add Cursor Up"] = "<C-Up>", -- Tambah kursor ke atas
		}
	end,
	lazy = false, -- Wajib agar langsung aktif saat Neovim dibuka
}
