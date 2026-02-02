local M = {}
local defaults = {
    light_theme = "rose-pine-dawn",
    dark_theme = "rose-pine-moon",
    cached_is_light_mode = nil,
}

M.is_os_theme_light = function(callback)
    callback = vim.schedule_wrap(callback)
    if vim.fn.has("win32") == 1 then
        vim.system({
            "reg",
            "query",
            "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
            "/v",
            "AppsUseLightTheme",
        }, { text = true }, function(result)
            if result.code ~= 0 then
                callback(false)
                return
            end
            callback(result.stdout:match("0x1") ~= nil)
        end)
    else
        vim.system(
            { "defaults", "read", "-g", "AppleInterfaceStyle" },
            { text = true },
            function(result)
                if result.code ~= 0 then
                    callback(true)
                else
                    callback(not result.stdout:match("Dark"))
                end
            end
        )
    end
end

function M.set_theme(is_light_mode)
    local preference_changed = M.cached_is_light_mode ~= is_light_mode
    if preference_changed then
        local colorscheme = is_light_mode and M.light_theme or M.dark_theme
        vim.cmd.colorscheme(colorscheme)
        M.cached_is_light_mode = is_light_mode
        vim.g.colors_name = colorscheme
    end
end

function M.toggle_os_theme()
    M.is_os_theme_light(function(current_is_light)
        local new_is_light = not current_is_light

        if vim.fn.has("win32") == 1 then
            local new_value = new_is_light and "1" or "0"
            vim.system({
                "reg",
                "add",
                "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
                "/v",
                "AppsUseLightTheme",
                "/t",
                "REG_DWORD",
                "/d",
                new_value,
                "/f",
            }, {}, function() end)
        else
            vim.system({
                "osascript",
                "-e",
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

        local new_theme = new_is_light and "Light" or "Dark"
        vim.schedule(function()
            vim.notify("OS Theme toggled to: " .. new_theme)
        end)
    end)
end

function M.setup(opts)
    opts = opts or {}
    M.light_theme = opts.light_theme or defaults.light_theme
    M.dark_theme = opts.dark_theme or defaults.dark_theme

    vim.schedule(function()
        M.is_os_theme_light(function(is_light_mode)
            M.set_theme(is_light_mode)
        end)
    end)
end

return M
