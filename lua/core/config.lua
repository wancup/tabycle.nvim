local M = {}

---@class TabycleConfigCycle
---@field width_ratio number
---@field height_ratio number
---@field auto_confirm_ms integer
---@field border string
---@field win_gap integer

---@class TabycleConfigHistory
---@field max_size integer

---@alias TabyclePositionValue integer | fun(): integer

---@class TabycleConfigPosition
---@field row TabyclePositionValue
---@field col TabyclePositionValue

---@class TabycleConfigSummary
---@field enabled boolean
---@field position TabycleConfigPosition
---@field border string
---@field cursor_icon string
---@field modified_icon string

---@class TabycleConfigList
---@field enabled boolean
---@field position TabycleConfigPosition
---@field border string
---@field cursor_icon string

---@class TabycleConfig
---@field cycle TabycleConfigCycle
---@field history TabycleConfigHistory
---@field summary TabycleConfigSummary
---@field list TabycleConfigList
---@field debounce_ms integer

---@type TabycleConfig
M.defaults = {
	cycle = {
		width_ratio = 0.8,
		height_ratio = 0.8,
		auto_confirm_ms = 1000,
		border = "rounded",
		win_gap = 2,
	},
	history = {
		max_size = 100,
	},
	summary = {
		enabled = true,
		position = { row = 2, col = -1 },
		border = "none",
		modified_icon = "*",
		cursor_icon = "^",
	},
	list = {
		enabled = false,
		position = { row = -3, col = -3 },
		border = "rounded",
		cursor_icon = ">",
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
