local M = {}
local defaults = {
  light_theme = 'rose-pine-dawn',
  dark_theme = 'rose-pine-moon',
  cached_is_light_mode = nil,
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
  M.cached_is_light_mode = is_light_mode
end

M.is_os_theme_light = function()
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
  local theme_changed = vim.g.colors_name ~= colorscheme

  if theme_changed then
    vim.cmd.colorscheme(colorscheme)
  end

  vim.defer_fn(function()
    local claude_theme = is_light_mode and 'light' or 'dark'
    pcall(function() return vim.system({ 'claude', 'config', 'set', '--global', 'theme', claude_theme }, {}) end)
  end, 0)

  vim.o.background = is_light_mode and 'light' or 'dark'
  M.save_theme_preference(is_light_mode)
end

function M.set_theme_based_on_os()
  local is_light_mode = M.is_os_theme_light()
  M.set_theme(is_light_mode)
end

function M.toggle_os_theme()
  local current_is_light = M.is_os_theme_light()
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
