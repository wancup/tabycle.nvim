local M = {}

---@class TabycleConfigCycleKeymaps
---@field close string
---@field open string
---@field open_split string
---@field open_vsplit string

---@class TabycleConfigCycleWin
---@field width_ratio number
---@field height_ratio number
---@field border string
---@field col_gap integer

---@class TabycleConfigCycle
---@field settle_ms integer
---@field keymaps TabycleConfigCycleKeymaps
---@field win TabycleConfigCycleWin

---@class TabycleConfigHistory
---@field max_size integer

---@alias TabyclePositionValue integer | fun(): integer

---@class TabycleConfigPosition
---@field row TabyclePositionValue
---@field col TabyclePositionValue

---@class TabycleConfigSummaryWin
---@field row TabyclePositionValue
---@field col TabyclePositionValue
---@field border string

---@class TabycleConfigSummary
---@field enabled boolean
---@field cursor_icon string
---@field modified_icon string
---@field win TabycleConfigSummaryWin

---@class TabycleConfigListWin
---@field row TabyclePositionValue
---@field col TabyclePositionValue
---@field border string

---@class TabycleConfigList
---@field enabled boolean
---@field cursor_icon string
---@field win TabycleConfigListWin

---@class TabycleConfig
---@field cycle TabycleConfigCycle
---@field history TabycleConfigHistory
---@field summary TabycleConfigSummary
---@field list TabycleConfigList
---@field debounce_ms integer

---@type TabycleConfig
M.defaults = {
	cycle = {
		settle_ms = 1000,
		keymaps = {
			close = "q",
			open = "<cr>",
			open_split = "<c-s>",
			open_vsplit = "<c-v>",
		},
		win = {
			width_ratio = 0.8,
			height_ratio = 0.8,
			border = "rounded",
			col_gap = 2,
		},
	},
	history = {
		max_size = 100,
	},
	summary = {
		enabled = true,
		modified_icon = "*",
		cursor_icon = "^",
		win = {
			row = 2,
			col = -1,
			border = "none",
		},
	},
	list = {
		enabled = false,
		cursor_icon = ">",
		win = {
			row = -3,
			col = -3,
			border = "rounded",
		},
	},
	debounce_ms = 100,
}

---@type TabycleConfig
M.options = M.defaults

---@param opts TabycleConfig | nil
function M.init(opts)
	M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
