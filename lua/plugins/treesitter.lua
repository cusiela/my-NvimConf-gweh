return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false,
		config = function()
			local ts = require("nvim-treesitter")
			local wanted = { "python", "cpp", "lua", "c", "vim", "vimdoc", "query", "javascript", "html" }

			local installed = {}
			for _, lang in ipairs(require("nvim-treesitter.config").get_installed("parsers")) do
				installed[lang] = true
			end
			local missing = vim.tbl_filter(function(l) return not installed[l] end, wanted)
			if #missing > 0 then
				ts.install(missing)
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("custom.treesitter", { clear = true }),
				callback = function(ev)
					-- highlight + indent hanya jika parser untuk filetype ini tersedia
					if pcall(vim.treesitter.start, ev.buf) then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
}
