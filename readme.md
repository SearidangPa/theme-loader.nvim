## What is theme-loader?
* Automatically loads themes based on the OS theme.
* API to toggle the OS theme and nvim theme accordingly.
* To speed up loading, it has a cache file that stores the last used theme. Then, in the background, 
it checks the OS theme and loads a different theme if it is different from the last one. Because of this, the first time
you load it after you change the OS theme, it will have a bit of jarring flash.
* Only works for mac and windows, because i don't have linux


## How I set it up
```lua 
return {
  {
    'SearidangPa/theme-loader.nvim',
    lazy = false,
    priority = 1000,
    config = function() require('theme-loader').setup() end,
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = true,
    config = true,
    opts = {
      variant = 'moon',
      styles = {
        italic = false,
      },
    },
  },
}
```

## API 
* `toggle_os_theme()` will toggle the OS theme and nvim theme accordingly and save the current theme to a cache file
* `sync_claude_theme` option will also update the Claude CLI theme when the OS theme preference changes (requires `claude` in PATH)


## Default Options

```lua
  {
    light_theme= 'rose-pine-dawn',
    dark_theme= 'rose-pine-moon',
    sync_claude_theme = false,
  },
```


## Demo 
https://github.com/user-attachments/assets/a99232c0-8adb-49ef-85af-c1f7d818957b
