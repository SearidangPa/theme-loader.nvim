local M = {}
local defaults = {
  light_theme = 'rose-pine-dawn',
  dark_theme = 'rose-pine-moon',
}
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
    local handle = io.popen 'reg query "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v AppsUseLightTheme 2>nul'
    if not handle then
      return false
    end
    local result = handle:read '*a'
    handle:close()
    if result and result ~= '' then
      return result:match '0x1' ~= nil
    else
      return false
    end
  else
    local result = vim.system({ 'defaults', 'read', '-g', 'AppleInterfaceStyle' }, { text = true }):wait()
    if result.code ~= 0 then
      return true
    end
    return not result.stdout:match 'Dark'
  end
end

function M.set_theme(is_light_mode)
  local colorscheme = is_light_mode and M.light_theme or M.dark_theme
  if vim.g.colors_name ~= colorscheme then
    vim.cmd.colorscheme(colorscheme)
  end

  local claude_theme = is_light_mode and 'light' or 'dark'
  vim.defer_fn(function()
    pcall(function() return vim.system({ 'claude', 'config', 'set', '--global', 'theme', claude_theme }, {}):wait() end)
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
  local current_is_light = get_os_theme()
  local new_is_light = not current_is_light

  if vim.fn.has 'win32' == 1 then
    local new_value = new_is_light and '1' or '0'
    vim.system({
      'reg',
      'add',
      'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize',
      '/v',
      'AppsUseLightTheme',
      '/t',
      'REG_DWORD',
      '/d',
      new_value,
      '/f',
    }, {}, function() end)
  else
    vim.system({
      'osascript',
      '-e',
      [[
      tell application "System Events"
        tell appearance preferences
          set dark mode to not dark mode
        end tell
      end tell
    ]],
    }, {}, function() end)
  end

  M.set_theme(new_is_light)
  M.save_theme_preference(new_is_light)

  local new_theme = new_is_light and 'Light' or 'Dark'
  vim.notify('OS Theme toggled to: ' .. new_theme)
end

function M.setup(opts)
  opts = opts or {}
  M.light_theme = opts.light_theme or defaults.light_theme
  M.dark_theme = opts.dark_theme or defaults.dark_theme

  if not vim.g.colors_name then
    M.set_theme(load_theme_preference())
  end

  vim.defer_fn(M.set_theme_based_on_os, 0)
end

return M
