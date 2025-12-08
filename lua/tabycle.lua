local autocmd = require("core.autocmd")
local tab = require("core.tab")
local buffer_summary = require("core.buffer_summary")
local buffer_list = require("core.buffer_list")
local buffer_cycle = require("core.buffer_cycle")

local M = {}

M.show_summary = function()
	tab.clear_cache()
	buffer_summary.show()
end

M.close_summary = function()
	buffer_summary.close()
end

M.toggle_summary = function()
	tab.clear_cache()
	buffer_summary.toggle()
end

M.show_list = function()
	tab.clear_cache()
	buffer_list.show()
end

M.close_list = function()
	buffer_list.close()
end

M.toggle_list = function()
	tab.clear_cache()
	buffer_list.toggle()
end

M.cycle_buffer_back = function()
	buffer_cycle.cycle_back(false)
end

M.cycle_buffer_forward = function()
	buffer_cycle.cycle_forward(false)
end

M.pick_prev_buffer = function()
	buffer_cycle.cycle_back(true)
end

M.pick_next_buffer = function()
	buffer_cycle.cycle_forward(true)
end

M.setup = function()
	-- TODO: skip initialization if unnecessary
	autocmd.init()

	vim.schedule(function()
		M.show_summary()
		M.show_list()
	end)
end

return M
