vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

-- Resize split window (Alt+panah; Ctrl+panah dipakai vim-visual-multi)
vim.keymap.set('n', '<A-Left>', ':vertical resize -2<CR>', { silent = true })
vim.keymap.set('n', '<A-Right>', ':vertical resize +2<CR>', { silent = true })
vim.keymap.set('n', '<A-Up>', ':resize +2<CR>', { silent = true })
vim.keymap.set('n', '<A-Down>', ':resize -2<CR>', { silent = true })
