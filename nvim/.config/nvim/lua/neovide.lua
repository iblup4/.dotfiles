-- Neovide settings, matched to kitty (~/.config/kitty/kitty.conf)

-- Font -----------------------------------------------------------------------
-- kitty: font_family Agave, font_size 26, and Nerd Font icons from
-- "JetBrainsMono Nerd Font" (symbol_map). Neovide uses the next font in the
-- list for any glyph the first one lacks, which covers the icons.
-- #e-antialias = grayscale smoothing like kitty on macOS (subpixelantialias looks bolder).
vim.o.guifont = "Agave,JetBrainsMono Nerd Font:h26:#e-antialias:#h-none"
-- vim.o.guifont = "JetBrains Mono:h25:#e-subpixelantialias:#h-none"
-- vim.o.guifont = "Iosevka:h25:#e-subpixelantialias:#h-none"

-- kitty: modify_font cell_height -2px
vim.o.linespace = -2

-- Cursor: glide like VS Code's smooth caret, no trail ---------------------------
vim.g.neovide_cursor_animation_length = 0.08       -- jumps (w, j, search, ...)
vim.g.neovide_cursor_short_animation_length = 0.06 -- 1-2 cell moves, i.e. typing
vim.g.neovide_cursor_trail_size = 0                -- whole cursor moves together: a slide, not a smear
vim.g.neovide_cursor_animate_in_insert_mode = true
vim.g.neovide_cursor_animate_command_line = true
vim.g.neovide_cursor_vfx_mode = ""

-- Cursor color like kitty: #c7c7c7 block, text under it in the background color
local function set_cursor_hl()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  vim.api.nvim_set_hl(0, "NeovideCursor", { bg = "#c7c7c7", fg = normal.bg })
end
set_cursor_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_cursor_hl })
vim.opt.guicursor = "n-v-c-sm:block-NeovideCursor,i-ci-ve:ver25-NeovideCursor,r-cr-o:hor20-NeovideCursor,t:block-blinkon500-blinkoff500-TermCursor"

-- Rendering / scrolling --------------------------------------------------------
vim.g.neovide_refresh_rate = 180
vim.g.neovide_scroll_animation_length = 0.3
-- vim.g.neovide_scroll_animation_length = 0.1
