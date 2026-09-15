return {
  "lopi-py/luau-lsp.nvim",
  ft = "luau",
  config = function ()
    local function rojo_project()
      return vim.fs.root(0, function(name)
        return name:match ".+%.project%.json$"
      end)
    end

    if rojo_project() then
      vim.filetype.add {
        extension = {
          lua = function(path)
            return path:match "%.nvim%.lua$" and "lua" or "luau"
          end,
        },
      }
    end

    require("luau-lsp").setup({
      platform = {
        roblox = true,
      },
      fflags = {
        enable_new_solver = true, -- enables the fflags required for luau's new type solver
        sync = true, -- sync currently enabled fflags with roblox's published fflags
        override = { -- override fflags passed to luau 
          LuauTableTypeMaximumStringifierLength = "100",
        },
      },
      sourcemap = {
        enabled = true,
        autogenerate = true,
        rojo_project_file = "default.project.json",
        sourcemap_file = "sourcemap.json",
      },
      plugin = {
        enabled = true,
        port = 3667,
      },
    })
    vim.lsp.config("luau-lsp", {
      root_dir = function(bufnr, on_dir)
        local root = vim.fs.root(bufnr, function(name, path)
          if path:match "/Packages/_Index/" or path:match "/DevPackages/_Index/" then
            return false
          end
          return name:match "^.+%.project%.json$" or name == ".git"
        end)
        on_dir(root)
      end,
      settings = {
        ["luau-lsp"] = {
          completion = {
            fillCallArguments = false,
            addParentheses = false,
            imports = {
              enabled = true,
              requireStyle = "alwaysAbsolute"
            }
          },
          hover = {
            multilineFunctionDefinitions = true,
            showTableKinds = true
          }
        },
      },
    })
  end
}
