-- ~/.config/nvim/lua/config/transparency.lua
--
-- Transparansi terpusat: mengosongkan background SEMUA jenis window
-- (normal, floating, plugin popup) supaya gambar background Ghostty
-- selalu terlihat. Dipasang lewat autocmd ColorScheme supaya tetap
-- bertahan walau tema dimuat ulang.

local groups = {
	-- dasar
	'Normal', 'NormalNC', 'EndOfBuffer', 'SignColumn', 'LineNr',
	-- floating window (ini yang bikin popup kamu "menutupi" background)
	'NormalFloat', 'FloatBorder', 'FloatTitle',
	-- popup menu completion
	'Pmenu',
	-- nvim-tree
	'NvimTreeNormal', 'NvimTreeNormalNC', 'NvimTreeNormalFloat',
	'NvimTreeEndOfBuffer', 'NvimTreeWinSeparator',
	-- telescope
	'TelescopeNormal', 'TelescopeBorder',
	'TelescopePromptNormal', 'TelescopePromptBorder',
	'TelescopeResultsNormal', 'TelescopeResultsBorder',
	'TelescopePreviewNormal', 'TelescopePreviewBorder',

	-- which-key
	"WhichKey",
	"WhichKeyBorder",
	"WhichKeyDesc",
	"WhichKeyGroup",
	"WhichKeyIcon",
	"WhichKeyIconAzure",
	"WhichKeyIconBlue",
	"WhichKeyIconCyan",
	"WhichKeyIconGreen",
	"WhichKeyIconGrey",
	"WhichKeyIconOrange",
	"WhichKeyIconPurple",
	"WhichKeyIconRed",
	"WhichKeyIconYellow",
	"WhichKeyNormal",
	"WhichKeySeparator",
	"WhichKeyTitle",
	"WhichKeyValue",
	-- CARA TAMBAH GRUP LAIN: kalau ada plugin popup lain yang masih
	-- solid, cari nama highlight group-nya (biasanya di :help plugin
	-- tersebut atau lewat :Telescope highlights), tambahkan ke daftar ini.
}

local function apply_transparency()
	for _, group in ipairs(groups) do
		-- PENTING: nvim_set_hl MENGGANTI seluruh definisi grup, bukan
		-- menambal. Jadi kita baca dulu definisi yang ada, buang HANYA
		-- background-nya, lalu tulis balik -- supaya warna teks (fg),
		-- bold/italic, dll tetap utuh.
		local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
		if ok then
			hl.bg = nil
			hl.ctermbg = nil
			pcall(vim.api.nvim_set_hl, 0, group, hl)
		end
	end
end

vim.api.nvim_create_autocmd('ColorScheme', {
	group    = vim.api.nvim_create_augroup('custom.transparency', { clear = true }),
	callback = apply_transparency,
})

-- Terapkan juga langsung sekarang (untuk tema yang sudah terlanjur aktif)
apply_transparency()
