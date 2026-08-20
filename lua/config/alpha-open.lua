-- ~/.config/nvim/lua/config/alpha-open.lua
--
-- Memastikan `nvim .` / `nvim <folder>` menampilkan alpha dashboard,
-- bukan buffer direktori (yang otomatis terbuka & menutupi alpha).

vim.api.nvim_create_autocmd('VimEnter', {
	group    = vim.api.nvim_create_augroup('custom.alpha.dir', { clear = true }),
	callback = function(data)
		if vim.fn.argc() ~= 1 then
			return
		end
		local arg = data.file
		if arg == '' or vim.fn.isdirectory(arg) ~= 1 then
			return
		end

		vim.cmd.cd(arg)
		pcall(vim.api.nvim_buf_delete, data.buf, { force = true })

		-- Panggil alpha manual setelah startup selesai
		vim.schedule(function()
			local ok, alpha = pcall(require, 'alpha')
			if ok then
				alpha.start(false)
			end
		end)
	end,
	nested   = true,
})
