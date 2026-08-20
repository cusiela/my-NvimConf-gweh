-- ~/.config/nvim/lua/config/ghostty-bg.lua
--
-- ============================ CATATAN KESELAMATAN ==========================
-- Script ini menulis config Ghostty + kirim SIGUSR2 (reload) ke SEMUA
-- proses ghostty. Reload memaksa Ghostty membaca ulang config dan
-- me-render ulang gambar background (proses GPU).
--
-- Versi ini punya RATE LIMIT (maks 1 reload per 400ms) dan KILL SWITCH:
--   :GhosttyBgToggle  -> nyalakan/matikan fitur ini di runtime
-- Kalau laptop kamu masih sering crash saat fitur ini nyala, matikan
-- dengan command itu (atau hapus require-nya di lazy.lua) dan amati --
-- kestabilan sistem lebih penting dari pergantian background.
-- ============================================================================

local DEBUG   = true
local enabled = true

local function find_ghostty_config()
	local candidates = {
		vim.fn.expand('~/.config/ghostty/config.ghostty'),
		vim.fn.expand('~/.config/ghostty/config'),
	}
	for _, path in ipairs(candidates) do
		if vim.fn.filereadable(path) == 1 then
			return path
		end
	end
	return candidates[1]
end

local ghostty_config_path   = find_ghostty_config()
local ghostty_config_backup = ghostty_config_path .. '.before-nvim-bg.bak'

-- ==========================================================================
-- ATUR GAMBAR DI SINI (path absolut)
-- position: top-left .. bottom-right | fit: cover, contain, none | opacity: 0-1
-- ==========================================================================
local img_idle              = {
	path     = '/home/cusiela/.config/nvim/assets/terminal.png',
	position = 'bottom-right',
	fit      = 'none',
	opacity  = 0.85,
}
local img_tree              = {
	path     = '/home/cusiela/.config/nvim/assets/dash.png',
	position = 'center',
	fit      = 'contain',
	opacity  = 0.9,
}
local img_workspace         = {
	path     = '/home/cusiela/.config/nvim/assets/Popcat-Kiri.png',
	position = 'bottom-right',
	fit      = 'contain',
	opacity  = 0.5,
}

local RELOAD_SIGNAL         = 'USR2' -- JANGAN diubah: signal lain bisa crash Ghostty

local current_state         = nil

local function dbg(msg)
	if DEBUG then
		vim.notify('[ghostty-bg] ' .. msg, vim.log.levels.INFO)
	end
end

local function ensure_backup()
	if vim.fn.filereadable(ghostty_config_backup) == 0
		and vim.fn.filereadable(ghostty_config_path) == 1 then
		local ok, lines = pcall(vim.fn.readfile, ghostty_config_path)
		if ok then
			pcall(vim.fn.writefile, lines, ghostty_config_backup)
		end
	end
end

local function format_line(key, value)
	return string.format('%s = %s', key, value)
end

local function set_config_keys(kv)
	if vim.fn.filereadable(ghostty_config_path) == 0 then
		dbg('GAGAL: config tidak ditemukan: ' .. ghostty_config_path)
		return false
	end
	local ok, lines = pcall(vim.fn.readfile, ghostty_config_path)
	if not ok then
		dbg('GAGAL: tidak bisa baca ' .. ghostty_config_path)
		return false
	end

	local remaining = {}
	for k in pairs(kv) do remaining[k] = true end

	for i, line in ipairs(lines) do
		for k, v in pairs(kv) do
			local escaped_key = k:gsub('%-', '%%-')
			if line:match('^' .. escaped_key .. '%s*=') then
				lines[i] = format_line(k, v)
				remaining[k] = nil
			end
		end
	end
	for k in pairs(remaining) do
		table.insert(lines, format_line(k, kv[k]))
	end

	local write_ok = pcall(vim.fn.writefile, lines, ghostty_config_path)
	if not write_ok then
		dbg('GAGAL: tidak bisa menulis ' .. ghostty_config_path)
	end
	return write_ok
end

-- Eksekusi sesungguhnya: tulis config + kirim signal
local function apply_bg(img, label)
	local state_id = table.concat({ img.path, img.position, img.fit, tostring(img.opacity) }, '|')
	if current_state == state_id then
		return
	end
	if vim.fn.filereadable(img.path) ~= 1 then
		dbg('DILEWATI [' .. label .. ']: gambar tidak ada -> ' .. img.path)
		return
	end
	local ok = set_config_keys({
		['background-image']          = img.path,
		['background-image-position'] = img.position,
		['background-image-fit']      = img.fit,
		['background-image-opacity']  = img.opacity,
	})
	if ok then
		vim.fn.system({ 'pkill', '-' .. RELOAD_SIGNAL, 'ghostty' })
		current_state = state_id
		dbg('OK [' .. label .. '] -> ' .. vim.fn.fnamemodify(img.path, ':t'))
	end
end

-- ==========================================================================
-- RATE LIMITER: permintaan yang datang beruntun dikoalisi -- cuma yang
-- TERAKHIR yang dieksekusi, maksimal 1 reload per 400ms. Ini pengaman
-- utama terhadap spam signal ke Ghostty (tersangka penyebab crash).
-- ==========================================================================
local pending = nil
local waiting = false

local function set_bg(img, label)
	if not enabled then return end
	pending = { img = img, label = label }
	if waiting then return end
	waiting = true
	vim.defer_fn(function()
		waiting = false
		if pending then
			local p = pending
			pending = nil
			apply_bg(p.img, p.label)
		end
	end, 400)
end

-- ==========================================================================
-- Commands
-- ==========================================================================
vim.api.nvim_create_user_command('GhosttyBgToggle', function()
	enabled = not enabled
	vim.notify('[ghostty-bg] ' .. (enabled and 'AKTIF' or 'NONAKTIF'), vim.log.levels.WARN)
end, { desc = 'Nyalakan/matikan pergantian background' })

vim.api.nvim_create_user_command('GhosttyBgDebug', function()
	local report = {
		'Status                 : ' .. (enabled and 'AKTIF' or 'NONAKTIF'),
		'File config terdeteksi : ' .. ghostty_config_path,
		'  ada?                 : ' .. tostring(vim.fn.filereadable(ghostty_config_path) == 1),
		'  bisa ditulis?        : ' .. tostring(vim.fn.filewritable(ghostty_config_path) == 1),
		'Gambar idle            : ' .. tostring(vim.fn.filereadable(img_idle.path) == 1) .. '  ' .. img_idle.path,
		'Gambar tree            : ' .. tostring(vim.fn.filereadable(img_tree.path) == 1) .. '  ' .. img_tree.path,
		'Gambar workspace       : ' ..
		tostring(vim.fn.filereadable(img_workspace.path) == 1) .. '  ' .. img_workspace.path,
		'State terakhir         : ' .. tostring(current_state),
		'Buffer sekarang        : filetype=' .. vim.bo.filetype .. '  buftype=' .. vim.bo.buftype,
	}
	vim.notify(table.concat(report, '\n'), vim.log.levels.INFO)
end, { desc = 'Diagnosa ghostty-bg' })

-- ==========================================================================
-- Autocmds
-- ==========================================================================
local augroup = vim.api.nvim_create_augroup('custom.ghostty_bg', { clear = true })

vim.api.nvim_create_autocmd('VimEnter', {
	group    = augroup,
	callback = ensure_backup,
})

vim.api.nvim_create_autocmd('FileType', {
	group    = augroup,
	pattern  = 'NvimTree',
	callback = function()
		set_bg(img_tree, 'tree')
	end,
})

-- BufEnter + WinEnter (BUKAN WinClosed seperti versi lalu -- itu kepicu
-- untuk SEMUA window yang tertutup termasuk popup completion/hover,
-- menyebabkan spam reload). WinEnter menangkap momen fokus kembali ke
-- window file setelah float tertutup, karena BufEnter tidak selalu
-- kepicu di kasus itu (buffernya sudah aktif sebelumnya).
vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
	group    = augroup,
	callback = function()
		local ft = vim.bo.filetype
		if ft == 'NvimTree' then
			set_bg(img_tree, 'tree')
			return
		end
		if vim.bo.buftype ~= '' then
			return
		end
		set_bg(img_workspace, 'workspace')
	end,
})

vim.api.nvim_create_autocmd('VimLeavePre', {
	group    = augroup,
	callback = function()
		-- Langsung (tanpa rate limiter): nvim sedang menutup diri,
		-- defer_fn tidak akan sempat jalan.
		if enabled then
			apply_bg(img_idle, 'idle')
		end
	end,
})
