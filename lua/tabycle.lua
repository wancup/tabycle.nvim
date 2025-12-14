local config = require("core.config")
local autocmd = require("core.autocmd")
local buffer_summary = require("core.buffer_summary")
local buffer_list = require("core.buffer_list")
local buffer_cycle = require("core.buffer_cycle")

local M = {}

function M.show_summary()
	buffer_summary.show()
end

function M.close_summary()
	buffer_summary.close()
end

function M.toggle_summary()
	buffer_summary.toggle()
end

function M.show_list()
	buffer_list.show()
end

function M.close_list()
	buffer_list.close()
end

function M.toggle_list()
	buffer_list.toggle()
end

function M.cycle_buffer_back()
	buffer_cycle.cycle_back()
end

function M.cycle_buffer_forward()
	buffer_cycle.cycle_forward()
end

---@param opts TabycleConfig | nil
function M.setup(opts)
	config.init(opts)
	autocmd.init()

	vim.schedule(function()
		M.show_summary()
		M.show_list()
	end)
end

return M
