local M = {}

M.cache_dir = vim.fn.stdpath 'cache' .. '/theme_preference'
M.light_cache_file = M.cache_dir .. '/light.txt'
M.dark_cache_file = M.cache_dir .. '/dark.txt'

M.config = {
  light_theme = {
    colorscheme = 'catppuccin-latte',
    lualine_theme = 'catppuccin-latte',
  },
  dark_theme = {
    colorscheme = 'rose-pine',
    lualine_theme = 'rose-pine',
  },
}

function M.set_theme(opts)
  local is_light_mode = opts.is_light_mode or false
  local mode = is_light_mode and 'light' or 'dark'
  local theme_config = is_light_mode and M.config.light_theme or M.config.dark_theme

  if vim.g.colors_name ~= theme_config.colorscheme then
    vim.cmd.colorscheme(theme_config.colorscheme)
  end

  local function lualine_refresh()
    local ok, lualine = pcall(require, 'lualine')
    if ok then
      local theme_name = mode == 'light' and M.config.light_theme.lualine_theme or M.config.dark_theme.lualine_theme
      lualine.refresh {
        options = {
          theme = theme_name,
        },
      }
    end
  end

  lualine_refresh()
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  vim.fn.mkdir(M.cache_dir, 'p')

  if not vim.g.colors_name then
    local function load_prev_theme_preference()
      local light_stat = vim.uv.fs_stat(M.light_cache_file)
      return light_stat ~= nil
    end

    local is_light_mode = load_prev_theme_preference()
    M.set_theme { is_light_mode = is_light_mode }
  end

  vim.schedule(function()
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

    local function save_theme_preference(local_opts)
      local is_light_mode = local_opts.is_light_mode or false

      if is_light_mode then
        vim.fn.writefile({}, M.light_cache_file)
        local dark_stat = vim.loop.fs_stat(M.dark_cache_file)
        if dark_stat then
          vim.uv.fs_unlink(M.dark_cache_file)
        end
      else
        vim.fn.writefile({}, M.dark_cache_file)
        local light_stat = vim.loop.fs_stat(M.light_cache_file)
        if light_stat then
          vim.uv.fs_unlink(M.light_cache_file)
        end
      end
    end

    local is_light_mode_from_os = get_os_mode()
    M.set_theme { is_light_mode = is_light_mode_from_os }
    save_theme_preference { is_light_mode = is_light_mode_from_os }
  end)
end

return M
