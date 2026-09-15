require("lazy_init")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function() require("nvim-surround").setup({ }) end
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      -- disabled for surrond.nvim to work
      -- { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
      { "<esc>", mode = { "n", "x", "o", "c" },
        function()
          require("flash").toggle(false)
          vim.snippet.stop()
          vim.cmd('noh')
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true), "n", true)
        end,
        desc = "Toggle Flash Search Off",
      },
    },
  },
  { import = "plugins_always" },
  { import = "plugins_notvscode", cond = (function() return not vim.g.vscode end) },
  -- { import = "plugins_vscode",    cond = (function() return vim.g.vscode end) },
})

vim.opt.numberwidth = 3
vim.opt.signcolumn = "yes:1"
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.termguicolors = true
vim.opt.updatetime = 750

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smarttab = true
vim.opt.softtabstop = 0
vim.opt.expandtab = true
vim.opt.list = true
vim.opt.listchars = "tab:  "

vim.opt.guicursor = "a:block-Cursor"
vim.api.nvim_set_hl(0, "Cursor", { reverse = true })
-- vim.opt.guicursor = {
--   'n-v-c:block-Cursor',
--   'i-ci:block-Cursor/lCursor-blinkon400-blinkoff400',
--   'r:block-Cursor'
-- }

-- vim.diagnostic.config({ virtual_text = true, update_in_insert = false, })

vim.opt.scrolloff = 5
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

vim.keymap.set("n", "<leader>o", "o<Esc>", { desc = "Add new line below" })
vim.keymap.set("n", "<leader>O", "O<Esc>", { desc = "Add new line above" })
vim.keymap.set('n', 'go', "<Cmd>call append(line('.'), repeat([''], v:count1))<CR>", { desc = "Add empty line below (count aware, preserves cursor)" })
vim.keymap.set('n', 'gO', "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>", { desc = "Add empty line above (count aware, preserves cursor)" })

local opts = { noremap = true, silent = true }

vim.keymap.set({"n", "v"}, "<leader>y", '"+y', opts)
vim.keymap.set({"n", "v"}, "<leader>p", '"+p', opts)
vim.keymap.set({"n", "v"}, "<leader>Y", '"+Y', opts)
vim.keymap.set({"n", "v"}, "<leader>P", '"+P', opts)

-- delete to clipboard
vim.keymap.set({"n", "v"}, "<leader>d", '"+d', { noremap = true, silent = true })

vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

vim.keymap.set("v", "J", ":m '>+1<CR>gv-gv", opts)
vim.keymap.set("v", "K", ":m '<-2<CR>gv-gv", opts)
-- vim.keymap.set("v", "J", ":m .+1<CR>==", opts)
-- vim.keymap.set("v", "K", ":m .-2<CR>==", opts)
-- vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv", opts)
-- vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv", opts)

vim.keymap.set('n', 'J', "mzJ`z")

-- make search in the middle
vim.keymap.set('n', 'n', "nzzzv")
vim.keymap.set('n', 'N', "Nzzzv")

vim.keymap.set('n', '<Esc>', function ()
  vim.snippet.stop()
  vim.cmd('noh')
end, { silent = true })

-- renames everything selected
vim.keymap.set("v", "<leader>r", ":s/\\%V/g<Left><Left>")

-- leave terminal mode
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

vim.keymap.set('n', '<leader>q', '<cmd>close!<CR>', { desc = "Close (force)" })

-- Navigate windows
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Go to Left Window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Go to Lower Window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Go to Upper Window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Go to Right Window' })

-- Resize windows
vim.keymap.set('n', '<C-S-k>', ':resize +2<CR>', { silent = true })
vim.keymap.set('n', '<C-S-j>', ':resize -2<CR>', { silent = true })
vim.keymap.set('n', '<C-S-h>', ':vertical resize -2<CR>', { silent = true })
vim.keymap.set('n', '<C-S-l>', ':vertical resize +2<CR>', { silent = true })

vim.keymap.set("i", "<S-Tab>", "<C-d>", opts)

vim.keymap.set('n', ']b', ':bnext<CR>', { noremap = true, silent = true, desc = 'Next buffer' })
vim.keymap.set('n', '[b', ':bprevious<CR>', { noremap = true, silent = true, desc = 'Previous buffer' })

vim.api.nvim_create_user_command('W', 'write', {})

vim.filetype.add({
  extension = {
    h = "c",
  },
})

-- no more comments on new lines
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:remove("c")
    vim.opt.formatoptions:remove("r")
    vim.opt.formatoptions:remove("o")
  end,
})

-- vim.api.nvim_create_autocmd("BufEnter", {
--   desc = "Set CWD to Oil directory",
--   callback = function()
--     local path = vim.api.nvim_buf_get_name(0)
--     if path:sub(1, 6) == "oil://" then
--       local real_path = path:sub(7)
--       vim.api.nvim_set_current_dir(real_path)
--     end
--   end,
-- })

local errors_only = false
vim.api.nvim_create_user_command("ErrorsOnly", function()
  errors_only = not errors_only

  if errors_only then
    vim.diagnostic.config({
      severity = { min = vim.diagnostic.severity.ERROR },
      virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
      signs = { severity = { min = vim.diagnostic.severity.ERROR } },
      underline = { severity = { min = vim.diagnostic.severity.ERROR } },
    })
    print("Diagnostics: errors only")
  else
    vim.diagnostic.config({
      severity = nil,
      virtual_text = { severity = nil },
      signs = { severity = nil },
      underline = { severity = nil },
    })
    print("Diagnostics: all levels")
  end
end, {})

vim.api.nvim_create_user_command(
  'RemoveCarriageReturns', function()
    vim.cmd('silent! %s/\\r//g')
    print("Carriage returns removed.")
  end,
  { desc = 'Remove carriage return characters from the buffer', }
)

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({
      timeout = 200, -- milliseconds
      -- Optional: change the highlight group
      -- higroup = "Visual",
    })
  end,
})

if vim.g.vscode then
  -- VSCode Neovim
  require("vscode_keymaps")
else
  local group = vim.api.nvim_create_augroup("ThemeCustomization", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    pattern = "*",
    callback = function()
      local visual = vim.api.nvim_get_hl(0, { name = "Visual" })
      vim.api.nvim_set_hl(0, "VisualNonText", {
        fg = "#707070",
        bg = visual.bg,
      })
    end,
  })

  vim.cmd.colorscheme("gruvdark")
  -- vim.cmd.colorscheme("vscode")
  -- vim.cmd.colorscheme("gruber-darker")
  -- vim.cmd.colorscheme("rose-pine")
end

if vim.g.neovide then
  require("neovide")
end

