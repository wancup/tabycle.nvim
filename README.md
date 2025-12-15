# tabycle.nvim

A Neovim plugin for intelligent buffer cycling with recency-based ordering, visual previews, and diagnostic indicators.

> [!Warning]
> This plugin is in early development. Breaking changes may occur without notice.

## Features

- **Buffer Cycling**: Two-stage buffer switching with visual preview and recency-based ordering
- **Buffer Summary**: A compact, always-visible indicator showing all open buffers with diagnostic status
- **Buffer List**: A detailed floating window displaying buffer names with modification and diagnostic markers

### Buffer Cycling

https://github.com/user-attachments/assets/9c496da5-2c7c-4ba7-9dc7-b8afba0cab83

### Buffer Summary

https://github.com/user-attachments/assets/58dcac0a-40f3-4bec-8d71-d50aee6abc8f

Look at the upper right small window.

### Buffer List

https://github.com/user-attachments/assets/29655f63-f1e4-4005-bdd4-32a0d26ba8f7

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "wancup/tabycle.nvim",
  event = "VeryLazy",
  keys = {
    { "<S-Tab>", "<cmd>Tabycle cycle back<cr>", desc = "Cycle to previous buffer" },
    { "<Tab>", "<cmd>Tabycle cycle forward<cr>", desc = "Cycle to next buffer" },
    { "<leader>bs", "<cmd>Tabycle summary toggle<cr>", desc = "Toggle buffer summary" },
    { "<leader>bl", "<cmd>Tabycle list toggle<cr>", desc = "Toggle buffer list" },
  },
  config = function()
    require("tabycle").setup() -- Required
  end,
}
```

> [!Note]
> The plugin tracks buffer history from when it's loaded. If loaded lazily (e.g., only via `keys`), buffers opened before the first keypress won't appear in the history. Use `event = "VeryLazy"` to start tracking early.

## Buffer Cycling Behavior

The buffer cycling feature (`cycle_buffer_back` / `cycle_buffer_forward`) implements a two-stage interaction model designed to optimize the most common use case: quickly switching to the previous buffer.

### Stage 1: Quick Switch (Single Input)

When you trigger buffer cycling for the first time:

1. The plugin immediately switches to the previous buffer in your recency history
2. A progress bar appears showing a countdown timer (default: 1000ms)
3. If you do nothing and the timer completes, the switch is confirmed and the new buffer becomes your current buffer

This behavior is optimized for the most frequent scenario: toggling between two files you're actively working on. A single keypress gets you to the previous buffer instantly.

### Stage 2: Full Preview (Second Input Within Timer)

If you trigger buffer cycling again before the timer expires:

1. The quick switch is cancelled and you return to your original buffer
2. A full buffer list appears on the left, showing all buffers sorted by recency
3. A preview window appears on the right, showing the content of the selected buffer
4. You can navigate the list with `j`/`k` and see live previews of each buffer
5. Press `<CR>` to open the selected buffer, `<C-s>` for horizontal split, `<C-v>` for vertical split, or `q` to cancel

> [!Note]
> If the selected buffer is already visible in another window, pressing `<CR>` will focus that window instead of loading the buffer into the current window.

### Why This Design?

This two-stage approach provides the best of both worlds:

- **Fast**: Single keypress for the most common operation (toggle between two files)
- **Powerful**: Double keypress reveals full navigation when you need to find a specific buffer
- **Predictable**: Buffers are always sorted by recency, so recently used files are at the top

## API / Commands

| Lua API | Command | Description |
|---------|---------|-------------|
| `require("tabycle").show_summary()` | `:Tabycle summary show` | Show the buffer summary |
| `require("tabycle").close_summary()` | `:Tabycle summary close` | Close the buffer summary |
| `require("tabycle").toggle_summary()` | `:Tabycle summary toggle` | Toggle the buffer summary |
| `require("tabycle").show_list()` | `:Tabycle list show` | Show the buffer list |
| `require("tabycle").close_list()` | `:Tabycle list close` | Close the buffer list |
| `require("tabycle").toggle_list()` | `:Tabycle list toggle` | Toggle the buffer list |
| `require("tabycle").cycle_buffer_back()` | `:Tabycle cycle back` | Cycle to previous buffer |
| `require("tabycle").cycle_buffer_forward()` | `:Tabycle cycle forward` | Cycle to next buffer |

## Configuration

```lua
require("tabycle").setup({
  cycle = {
    settle_ms = 1000,  -- Time to wait before confirming quick switch
    keymaps = {
      close = "q",           -- Close the cycle preview
      open = "<cr>",         -- Open selected buffer in current window
      open_split = "<c-s>",  -- Open selected buffer in horizontal split
      open_vsplit = "<c-v>", -- Open selected buffer in vertical split
    },
    win = {
      width_ratio = 0.8,   -- Width of cycle windows relative to editor
      height_ratio = 0.8,  -- Height of cycle windows relative to editor
      border = "rounded",  -- Border style for cycle windows
      col_gap = 2,         -- Gap between list and preview windows
    },
    progress_win = {
      row = 0,             -- Row position (number | function)
      col = 0,             -- Column position (number | function)
      border = "rounded",  -- Border style for progress bar
    },
  },
  history = {
    max_size = 100,  -- Maximum number of buffers to track in history
  },
  summary = {
    enabled = true,        -- Show buffer summary on startup
    modified_icon = "*",   -- Icon for modified buffers
    cursor_icon = "^",     -- Icon indicating current buffer
    win = {
      row = 0,             -- Row position (number | function)
      col = -1,            -- Column position (number | function)
      border = "none",     -- Border style
    },
  },
  list = {
    enabled = false,       -- Show buffer list on startup
    cursor_icon = ">",     -- Icon indicating current buffer
    win = {
      row = -3,            -- Row position (number | function)
      col = -3,            -- Column position (number | function)
      border = "rounded",  -- Border style
    },
  },
  debounce_ms = 100,  -- Debounce time for UI updates
})
```

## Visual Indicators

### Buffer Summary

The summary displays a compact row of icons representing each buffer:

- `.` - No diagnostics
- `E` - Error (highest severity)
- `W` - Warning
- `I` - Info
- `H` - Hint
- `*` - Modified buffer (overrides diagnostic icon)
- `^` - Current buffer indicator (shown below the icons)

- 

### Buffer List

Each buffer entry shows:

- Cursor icon (`>`) for current buffer
- File name
- `*` for modified buffers
- `[E]`, `[W]`, `[I]`, `[H]` for diagnostic severity
- Dimmed text for buffers not visible in any window

## Acknowledgments

This plugin was inspired by the following excellent plugins:

- [cybu.nvim](https://github.com/ghillb/cybu.nvim): A brilliant buffer cycling plugin that pioneered the concept of visual buffer switching with a notification window. tabycle.nvim extends this idea with a two-stage interaction model and full buffer preview.
- [buffer-sticks.nvim](https://github.com/ahkohd/buffer-sticks.nvim): An elegant buffer indicator that beautifully displays buffer status. Its clean design philosophy influenced the buffer summary feature in tabycle.nvim.

## TODO

Due to my current schedule, work on these items may not begin until March 2026 or later.

- [ ] Add vimdoc
- [ ] Display keymap cheatsheet
- [ ] Make highlight colors configurable
- [ ] Enable scrolling in preview window
- [ ] Enable buffer deletion from preview window
- [ ] Add option to disable auto-focus behavior for already-visible buffers
- [ ] Add tests
- [ ] Stabilize API
