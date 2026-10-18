-- macOS and native Linux use Neovim's clipboard auto-detection.
if vim.g.vscode or vim.g.clipboard ~= nil or vim.fn.has("wsl") ~= 1 then
  return
end

if vim.fn.executable("win32yank.exe") == 1 then
  -- Resolve symlinks into the Windows installation before invoking the tool.
  local executable = vim.fn.resolve(vim.fn.exepath("win32yank.exe"))
  vim.g.clipboard = {
    name = "win32yank (WSL)",
    copy = {
      ["+"] = { executable, "-i", "--crlf" },
      ["*"] = { executable, "-i", "--crlf" },
    },
    paste = {
      ["+"] = { executable, "-o", "--lf" },
      ["*"] = { executable, "-o", "--lf" },
    },
    cache_enabled = 0,
  }
elseif vim.fn.executable("powershell.exe") == 1 then
  local function powershell(script)
    return { "powershell.exe", "-NoLogo", "-NoProfile", "-NonInteractive", "-Command", script }
  end

  -- Set UTF-8 explicitly so Unicode survives the WSL/Windows boundary.
  local copy = powershell(
    '[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false); '
      .. 'Set-Clipboard -Value ([Console]::In.ReadToEnd())'
  )
  local paste = powershell(
    '[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false); '
      .. '[Console]::Out.Write(([string](Get-Clipboard -Raw)).Replace("`r", ""))'
  )
  vim.g.clipboard = {
    name = "PowerShell (WSL)",
    copy = { ["+"] = copy, ["*"] = copy },
    paste = { ["+"] = paste, ["*"] = paste },
    cache_enabled = 0,
  }
end
