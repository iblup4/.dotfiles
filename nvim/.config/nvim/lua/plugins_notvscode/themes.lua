function ApplyDefault()
  local highlights = {
    FlashBackdrop = { fg = "#52494e" },
    FlashLabel    = { fg = "#73c936", bold = true },
    FlashMatch    = { fg = "#9e95c7" },
    FlashCurrent  = { fg = "#ffdd33" },
    FlashPrompt   = { link = "NormalFloat" },
    FlashCursor   = { fg = "#ff8da1" }
  }

  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end

  vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#616161" })
end

return {
  {
    "Mofiqul/vscode.nvim"
  },
  {
    "folke/tokyonight.nvim",
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        styles = {
          bold = false,
          italic = false,
          transparency = false,
        },
      })

      local function apply_overrides()
        vim.api.nvim_set_hl(0, "Cursor", {
          fg = "#000000",
          bg = "#ffffff",
        })

        ApplyDefault()
      end

      local rose_group = vim.api.nvim_create_augroup("RoseOverrides", { clear = true })

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = rose_group,
        pattern = "*",
        callback = apply_overrides,
      })
    end,
  },
  {
    "darianmorat/shibumi.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    integrations = {
      treesitter = true,
    },
    config = function()
      require("catppuccin").setup({
        no_italic = true,
      })

      ApplyDefault()
    end,
  },
  {
    "blazkowolf/gruber-darker.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      bold = false,
      italic = {
        strings = false,
        comments = false,
        operators = false,
        folds = false,
      },
    },
    config = function()
      local function apply_overrides()
        if vim.g.colors_name ~= "gruber-darker" then
          return
        end

        vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#404040", bold = false })
        vim.api.nvim_set_hl(0, "LineNr", { fg = "#ffdd33", bold = false })
        vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#404040", bold = false })

        vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = "#ffffff", force = true })
        vim.api.nvim_set_hl(0, "@type.definition.c", {})
        vim.api.nvim_set_hl(0, "@number.c", { fg = "#ff6200" })

        ApplyDefault()
      end

      local gruber_group = vim.api.nvim_create_augroup("GruberOverrides", { clear = true })

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = gruber_group,
        pattern = "*",
        callback = apply_overrides,
      })
    end,
  },
}
