# 🙇 FOCUS.nvim

Distraction-free coding for Neovim >= 0.5. A fork of Folke's
[Zen Mode](https://github.com/folke/zen-mode.nvim/tree/main) with features inspired by
[True Zen](https://github.com/pocco81/true-zen.nvim/tree/main).

<img width="1802" alt="focus" src="https://github.com/user-attachments/assets/bca0224e-c686-4d00-9d9d-0599053367d5">

<details closed>
<summary>Click to toggle demo</summary>

https://github.com/user-attachments/assets/427866a5-52ec-4d6b-a399-859c38201c7e

</details>

## ✨ Features

3 modes: **FOCUS**, **NARROW**, and **ZEN**

ANY combination of **FOCUS**, **NARROW**, and **ZEN** can be activated at a time -- they work seamlessly together!

### 🙇 FOCUS mode

- opens the current buffer in a new full-screen floating window
- doesn't mess with existing window layouts / splits
- works correctly with other floating windows, like LSP hover, WhichKey, ...
- you can dynamically change the window size
- realigns when the editor or Focus window is resized
- optionally shade the backdrop of the Focus window
- highly customizable with lua callbacks `on_open`, `on_close`
- plugins (optional):
  - disable gitsigns
  - hide [tmux](https://github.com/tmux/tmux) status line
  - disable diagnostics
  - disable todo
- **FOCUS** is automatically closed when a new non-floating window is opened
- works well with plugins like [Telescope](https://github.com/nvim-telescope/telescope.nvim) to open a new buffer inside the Focus window
- close the Focus window with `:Focus`, `:close` or `:quit`

### 🔎 NARROW mode

- uses some simple folding ✨ *magic* ✨ to hide all but the selected lines
- activated by calling `:Narrow` with a range or selection of lines
- can be activated together with **FOCUS** by calling `:FOCUS` with a range or selection of lines
- can be repeatedly called with smaller selections to narrow focus further
- Note: because **NARROW** mode uses folds to hide unselected code, you will be unable
  to fold lines unless you manually define them (see `:h fold-methods`)

### 🧘 ZEN mode

- hides distractions (statusline, statuscolumn, etc.)
- optionally hide diagnostics

## ⚡️ Requirements

- Neovim >= 0.5.0

## 📦 Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- Lua
{
  "cdmill/focus.nvim",
  cmd = { "Focus", "Zen", "Narrow" },
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
}
```

## ⚙️ Configuration

FOCUS.nvim comes with the following defaults:

```lua
{
  border = "none",
  zindex = 40, -- zindex of the focus window. Should be less than 50, which is the float default
  window = {
    backdrop = 0.9, -- shade the backdrop of the focus window. Set to 1 to keep the same as Normal
    -- height and width can be:
    -- * an absolute number of cells when > 1
    -- * a percentage of the width / height of the editor when <= 1
    width = 120, -- width of the focus window
    height = 1, -- height of the focus window
    -- by default, no options are changed in for the focus window
    -- add any vim.wo options you want to apply
    options = {},
  },
  auto_zen = false, -- auto enable zen mode when entering focus mode
  maintain_zen = false, -- if true, stay in zen mode when exiting focus mode
  maintain_narrow = false, -- if true, stay in narrow mode when exiting focus mode
  -- by default, the options below are disabled for zen mode
  zen = {
    opts = {
      cmdheight = 0, -- disable cmdline
      cursorline = false, -- disable cursorline
      laststatus = 0, -- disable statusline
      number = false, -- disable number column
      relativenumber = false, -- disable relative numbers
      foldcolumn = "0", -- disable fold column
      signcolumn = "no", -- disable signcolumn
      statuscolumn = " ", -- disable status column
    },
    diagnostics = false, -- disables diagnostics
  },
  plugins = {
    -- uncomment any of the lines below to disable that option in Focus mode
    -- options = {
    --   disable some global vim options (vim.o...) e.g.
    --   ruler = false
    -- },
    -- twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
    -- gitsigns = { enabled = false }, -- disables git signs
    -- tmux = { enabled = false }, -- disables the tmux statusline
    -- diagnostics = { enabled = false }, -- disables diagnostics
    -- todo = { enabled = false }, -- if set to "true", todo-comments.nvim highlights will be disabled
  },
  -- callback where you can add custom code when the focus window opens
  on_open = function(_win) end,
  -- callback where you can add custom code when the focus window closes
  on_close = function() end,
}
```

## 🚀 Usage

- Toggle **FOCUS** mode with `:Focus`.
- Toggle **NARROW** mode with `:'<,'>Narrow`. (e.g. by typing `:Narrow` after visual selecting lines)
- Toggle **NARROW** and **FOCUS** mode with `:'<,'>Focus`. (e.g. by typing `:Focus` after visual selecting lines)
- Toggle **ZEN** mode with `:Zen`.

Alternatively you can start any of **FOCUS**, **ZEN**, or **NARROW** mode with the `Lua` API and pass any additional options:

```lua
require("focus").toggle({
  window = {
    width = .85 -- width will be 85% of the editor width
  }
})
require("focus").toggle_zen({
  zen = {
    opts = {
      number = true, -- enable number column
      relativenumber = true, -- enable relative numbers
      statuscolumn = "%=%{v:relnum?v:relnum:v:lnum} " -- enable statuscolumn with specific configuration
    }
  }
})
require("focus").toggle_narrow({
  line1 = beginning line number,
  line2 = ending line number
})
```

## Inspiration

- Visual Studio Code [Zen Mode](https://code.visualstudio.com/docs/getstarted/userinterface#_zen-mode)
- Emacs [writeroom-mode](https://github.com/joostkremers/writeroom-mode)
- Folke [Zen Mode](https://github.com/folke/zen-mode.nvim/tree/main)
- Pocco81 [True Zen](https://github.com/pocco81/true-zen.nvim/tree/main)
