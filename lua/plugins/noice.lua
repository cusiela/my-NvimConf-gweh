-- plugin untuk search
return {
	"folke/noice.nvim",
	enabled = false,
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		local noice = require("noice")

		noice.setup({
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = true,
				command_palette = false,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = false,
			},
			views = {
				cmdline_popup = {
					position = {
						row = 2,
						col = "95%",
					},
					size = {
						width = 40,
						height = "auto", -- FIX: dulu fixed 3 + border = kebesaran
					},
					border = {
						style = "rounded",
						padding = { 0, 1 },
					},
					win_options = {
						-- FIX: winhighlight harus string "Grup:Grup,...", bukan tabel
						winhighlight = "Normal:NoiceCmdlinePopupNormal,FloatBorder:NoiceCmdlinePopupBorder",
					},
				},
				popupmenu = {
					relative = "editor",
					position = {
						row = 5,
						col = "95%",
					},
					size = {
						width = 40,
						max_height = 10,
					},
					border = {
						style = "rounded",
					},
					win_options = {
						-- FIX: string, dan tambahkan Pmenu/PmenuSel
						-- karena popupmenu pakai highlight ini untuk daftar item
						winhighlight =
						"Normal:NoicePopupmenuNormal,FloatBorder:NoicePopupmenuBorder,Pmenu:NoicePopupmenuNormal,PmenuSel:NoicePmenuSel",
					},
				},
			},
		})

		-- === Integrasi dengan Telescope ===
		local telescopeOk, telescope = pcall(require, "telescope")
		if telescopeOk then
			pcall(telescope.load_extension, "noice")
		end

		vim.keymap.set("n", "<leader>sn", "<cmd>Telescope noice<cr>", { desc = "Search Noice History" })
		vim.keymap.set("n", "<leader>sh", "<cmd>Telescope noice search_history<cr>", { desc = "Search History" })

		-- === Background transparan (sungguhan) ===
		local function set_noice_transparent()
			vim.api.nvim_set_hl(0, "NoiceCmdlinePopupNormal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { bg = "none" })
			vim.api.nvim_set_hl(0, "NoicePopupmenuNormal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NoicePopupmenuBorder", { bg = "none" })
			vim.api.nvim_set_hl(0, "NoicePmenuSel", { bg = "none", bold = true })
		end
		set_noice_transparent()
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = set_noice_transparent,
		})
	end,
}
