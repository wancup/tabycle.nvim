local autocmd = require("core.autocmd")
local buffer_summary = require("core.buffer_summary")
local buffer_list = require("core.buffer_list")
local buffer_cycle = require("core.buffer_cycle")

local M = {}

M.show_summary = function()
	buffer_summary.show()
end

M.close_summary = function()
	buffer_summary.close()
end

M.toggle_summary = function()
	buffer_summary.toggle()
end

M.show_list = function()
	buffer_list.show()
end

M.close_list = function()
	buffer_list.close()
end

M.toggle_list = function()
	buffer_list.toggle()
end

M.cycle_buffer_back = function()
	buffer_cycle.cycle_back()
end

M.cycle_buffer_forward = function()
	buffer_cycle.cycle_forward()
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
