return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "comment",
        "css",
        "go",
        "graphql",
        "help",
        "html",
        "http",
        "javascript",
        "json",
        "latex",
        "lua",
        "python",
        "rust",
        "typescript",
      },

      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,
    },
    config = function()
      local ts = require("nvim-treesitter")

      -- local ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "javascript", "html", "python", "rust", "c_sharp" }
      --
      -- local already_installed = ts.get_installed()
      --
      -- local to_install = vim
      --   .iter(ensure_installed)
      --   :filter(function(parser)
      --     return not vim.tbl_contains(already_installed, parser)
      --   end)
      --   :totable()
      --
      -- if #to_install > 0 then
      --   ts.install(to_install)
      -- end

      -- vscode-neovim disables treesitter highlighting anyway; textobjects parse on demand
      if vim.g.vscode then return end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("EnableTreesitterHighlighting", { clear = true }),
        desc = "Try to enable tree-sitter syntax highlighting",
        pattern = "*", -- run on *all* filetypes
        callback = function()
          pcall(function()
            vim.treesitter.start()
          end)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    keys = function()
      local select = function(query, query_group)
        return function()
          require("nvim-treesitter-textobjects.select").select_textobject(query, query_group or "textobjects")
        end
      end

      return {
        { "af", select("@function.outer"), mode = { "x", "o" }, desc = "Select outer function" },
        { "if", select("@function.inner"), mode = { "x", "o" }, desc = "Select inner function" },
        { "ac", select("@class.outer"), mode = { "x", "o" }, desc = "Select outer class" },
        { "ic", select("@class.inner"), mode = { "x", "o" }, desc = "Select inner class" },
        { "as", select("@local.scope", "locals"), mode = { "x", "o" }, desc = "Select local scope" },
      }
    end,
    opts = {
      select = {
        enable = true,
        lookahead = true,
      },
    },
  },
}
