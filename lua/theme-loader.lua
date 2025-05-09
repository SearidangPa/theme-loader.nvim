local M = {}

M.cache_file = vim.fn.stdpath 'cache' .. '/theme_preference.txt'

M.config = {
  light_theme = {
    colorscheme = 'catppuccin-latte',
    lualine_theme = 'catppuccin-latte',
  },
  dark_theme = {
    colorscheme = 'rose-pine-moon',
    lualine_theme = 'rose-pine',
  },
}

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
  local file = io.open(M.cache_file, 'w')
  if file then
    file:write(is_light_mode and 'light' or 'dark')
    file:close()
  end
end

local function load_prev_theme_preference()
  local file = io.open(M.cache_file, 'r')
  if file then
    local content = file:read()
    file:close()
    return content == 'light'
  end
  return false
end

local function lualine_refresh(mode)
  local ok, lualine = pcall(require, 'lualine')
  if ok then
    local theme_name = mode == 'light' and M.config.light_theme.lualine_theme or M.config.dark_theme.lualine_theme

    lualine.setup {
      options = {
        theme = theme_name,
      },
    }
  end
end

local function set_theme(opts)
  local is_light_mode = opts.is_light_mode or false
  local mode = is_light_mode and 'light' or 'dark'
  local theme_config = is_light_mode and M.config.light_theme or M.config.dark_theme

  if is_light_mode and vim.g.colors_name ~= theme_config.colorscheme then
    vim.cmd.colorscheme(theme_config.colorscheme)
    lualine_refresh(mode)
  elseif not is_light_mode and vim.g.colors_name ~= theme_config.colorscheme then
    vim.cmd.colorscheme(theme_config.colorscheme)
    lualine_refresh(mode)
  end

  save_theme_preference { is_light_mode = is_light_mode }
end

function M.toggle_theme()
  local current_theme = load_prev_theme_preference()
  set_theme { is_light_mode = not current_theme }
end

function M.set_light_theme() set_theme { is_light_mode = true } end

function M.set_dark_theme() set_theme { is_light_mode = false } end

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  if not vim.g.colors_name then
    local is_light_mode = load_prev_theme_preference()
    set_theme { is_light_mode = is_light_mode }
  end

  vim.schedule(function()
    local is_light_mode_from_os = get_os_mode()
    set_theme { is_light_mode = is_light_mode_from_os }
  end)
end

return M
