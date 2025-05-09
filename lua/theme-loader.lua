local M = {}

M.cache_file = vim.fn.stdpath 'cache' .. '/theme_preference.txt'

M.config = {
  light_theme = {
    colorscheme = 'catppuccin-latte',
  },
  dark_theme = {
    colorscheme = 'rose-pine',
  },
}

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

function M.set_theme(opts)
  opts = opts or {}
  local is_light_mode = opts.is_light_mode or false
  local theme_config = is_light_mode and M.config.light_theme or M.config.dark_theme

  if vim.g.colors_name ~= theme_config.colorscheme then
    vim.cmd.colorscheme(theme_config.colorscheme)
  end

  local ok, lualine = pcall(require, 'lualine')
  if ok then
    lualine.refresh { options = { theme = theme_config.colorscheme } }
  end
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  if not vim.g.colors_name then
    M.set_theme { is_light_mode = load_theme_preference() }
  end

  vim.schedule(function()
    local is_light_mode = get_os_theme()
    M.set_theme { is_light_mode = is_light_mode }
    M.save_theme_preference(is_light_mode)
  end)
end

return M
