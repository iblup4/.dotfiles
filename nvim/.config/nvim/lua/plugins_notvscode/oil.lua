return {
  'stevearc/oil.nvim',
  config = function()
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    require('oil').setup({
      keymaps = {
        ["<C-h>"] = false,        -- disable oil's split-open on Ctrl-h
        ["<C-l>"] = false,        -- disable oil's refresh on Ctrl-l
      },
      default_file_explorer = true,
      columns = {
        -- "icon",
        -- "permissions",
        {"size", highlight = "Special"},
        "mtime",
      },
      delete_to_trash = false,
      skip_confirm_for_simple_edits = true,
      prompt_save_on_select_new_entry = false,
      constrain_cursor = 'name',
      lazy = false,
      watch_for_changes = true,
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _)
          return name == '..'
        end
      },
      win_options = {
        wrap = true,
        conceallevel = 3,
        concealcursor = "nvic",
      },
      confirmation = {
        border = 'single'
      },
    })
  end
}
