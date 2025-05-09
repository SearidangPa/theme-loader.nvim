local M = {}

local cache_file = vim.fn.stdpath 'cache' .. '/theme_preference.txt'
local function get_os_mode()
  local is_light = true
  if vim.fn.has 'win32' == 1 then
    local result = vim.fn.system 'reg query "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v AppsUseLightTheme'
    is_light = not result:match '0x0'
  else
    local result = vim.fn.system 'defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light"'
    is_light = not result:match 'Dark'
  end
  return is_light
end

local function save_theme_preference(opts)
  local is_light_mode = opts.is_light_mode or false
  local file = io.open(cache_file, 'w')
  if file then
    file:write(is_light_mode and 'light' or 'dark')
    file:close()
  end
end

local function load_prev_theme_preference()
  local file = io.open(cache_file, 'r')
  if file then
    local content = file:read()
    file:close()
    return content == 'light'
  end
  return false
end

local function lualine_refresh(theme_name)
  local ok, lualine = pcall(require, 'lualine')
  if ok then
    lualine.setup {
      options = {
        theme = theme_name,
      },
    }
  end
end

local function set_theme(opts)
  local is_light_mode = opts.is_light_mode or false
  if is_light_mode and vim.g.colors_name ~= 'catppuccin' then
    vim.cmd.colorscheme 'catppuccin-latte'
    lualine_refresh 'catppuccin-latte'
  elseif not is_light_mode and vim.g.colors_name ~= 'rose-pine' then
    vim.cmd.colorscheme 'rose-pine-moon'
    lualine_refresh 'rose-pine'
  end
  save_theme_preference { is_light_mode = is_light_mode }
end

if not vim.g.colors_name then
  local is_light_mode = load_prev_theme_preference()
  set_theme { is_light_mode = is_light_mode }
end

vim.schedule(function()
  local is_light_mode_from_os = get_os_mode()
  set_theme { is_light_mode = is_light_mode_from_os }
end)

return M
