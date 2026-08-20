return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    -- =====================================================================
    -- 🚀 FITUR BAWAAN ANDA (Sudah Diperbaiki)
    -- =====================================================================
    -- Tambah file ke list harpoon
    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: Add file" })
    -- Buka menu cepat harpoon (bawaan UI)
    vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: Toggle UI" })
    -- Navigasi file berikutnya / sebelumnya (Alt; <C-n> dipakai vim-visual-multi)
    vim.keymap.set("n", "<M-p>", function() harpoon:list():prev() end, { desc = "Harpoon: Previous file" })
    vim.keymap.set("n", "<M-n>", function() harpoon:list():next() end, { desc = "Harpoon: Next file" })

    -- Integrasi Telescope dengan tema Ivy (Pilihan Anda)
    vim.keymap.set("n", "<leader>fl", function()
        local conf = require("telescope.config").values
        local themes = require("telescope.themes")
        local file_paths = {}
        for _, item in ipairs(harpoon:list().items) do
            table.insert(file_paths, item.value)
        end
        require("telescope.pickers").new(themes.get_ivy({ prompt_title = "Harpoon Working List" }), {
            finder = require("telescope.finders").new_table({ results = file_paths }),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
        }):find()
    end, { desc = "Open harpoon window with Telescope" })

    -- =====================================================================
    -- 🔥 KONFIGURASI TAMBAHAN (Sangat Powerful!)
    -- =====================================================================
    -- Lompat langsung ke file spesifik di list menggunakan Leader + Angka
    -- Ini jauh lebih cepat daripada membuka menu UI terlebih dahulu!
    vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon: Go to file 1" })
    vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon: Go to file 2" })
    vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon: Go to file 3" })
    vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon: Go to file 4" })

    -- Sinkronisasi otomatis: Jika Anda menghapus baris teks di dalam UI Harpoon (<C-e>),
    -- nomor urut angka di atas akan otomatis bergeser naik/menyesuaikan.
  end,
}

