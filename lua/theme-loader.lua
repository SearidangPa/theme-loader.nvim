local M = {}
M.light_colorscheme = 'rose-pine-dawn'
M.dark_colorscheme = 'rose-pine-moon'
M.cache_file = vim.fn.stdpath 'cache' .. '/theme_preference.txt'

local function load_theme_preference()
  local file = io.open(M.cache_file, 'r')
  if not file then
    return false
  end
  local content = file:read()
  file:close()
  return content == 'light'
end

function M.save_theme_preference(is_light_mode)
  local file = io.open(M.cache_file, 'w')
  if not file then
    return
  end
  file:write(is_light_mode and 'light' or 'dark')
  file:close()
end

local function get_os_theme()
  if vim.fn.has 'win32' == 1 then
    return not vim.fn.system('reg query "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v AppsUseLightTheme'):match '0x0'
  else
    return not vim.fn.system('defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light"'):match 'Dark'
  end
end

function M.set_theme(is_light_mode)
  local colorscheme = is_light_mode and M.light_colorscheme or M.dark_colorscheme
  if vim.g.colors_name ~= colorscheme then
    vim.cmd.colorscheme(colorscheme)
  end

  vim.defer_fn(function()
    local ok, lualine = pcall(require, 'lualine')
    if ok then
      lualine.refresh { options = { theme = colorscheme } }
    end
  end, 1000)
end

function M.set_theme_based_on_os()
  local is_light_mode = get_os_theme()
  M.set_theme(is_light_mode)
  M.save_theme_preference(is_light_mode)
end

function M.toggle_os_theme()
  if vim.fn.has 'win32' == 1 then
    local is_light = get_os_theme()
    local new_value = is_light and '0' or '1'
    vim.fn.system(
      'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v AppsUseLightTheme /t REG_DWORD /d ' .. new_value .. ' /f'
    )
  else
    local script = [[
    osascript -e '
      tell application "System Events"
        tell appearance preferences
          set dark mode to not dark mode
        end tell
      end tell
    '
    ]]
    vim.fn.system(script)
  end
  local new_theme = get_os_theme() and 'Light' or 'Dark'
  M.set_theme(new_theme == 'Light')
  M.save_theme_preference(new_theme == 'Light')

  local ok, fidget = pcall(require, 'fidget')
  if ok then
    fidget.notify('OS Theme toggled to: ' .. new_theme)
  else
    vim.notify('OS Theme toggled to: ' .. new_theme)
  end
end

function M.setup()
  if not vim.g.colors_name then
    M.set_theme(load_theme_preference())
  end

  vim.defer_fn(M.set_theme_based_on_os, 1000)
end

return M
