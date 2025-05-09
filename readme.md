## What is theme-loader?
* Automatically loads themes based on the OS theme.
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
    'catppuccin/nvim',
    name = 'catppuccin',
    config = true,
    lazy = true,
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

## Default Options

```lua
{
  light_theme = {
    colorscheme = 'catppuccin-latte',
    lualine_theme = 'catppuccin-latte',
  },
  dark_theme = {
    colorscheme = 'rose-pine-moon',
    lualine_theme = 'rose-pine',
  },
}
```


## Demo 
https://github.com/user-attachments/assets/ab7f6f1a-1d34-4b5c-b499-033ea4efedec
