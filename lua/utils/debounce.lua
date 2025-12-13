local M = {}

---@param fn function
---@param ms number
---@return function
---@return function
function M.debounce(fn, ms)
	local timer = vim.uv.new_timer()
	local debounced = function(...)
		local args = { ... }
		if timer then
			timer:stop()
			timer:start(
				ms,
				0,
				vim.schedule_wrap(function()
					fn(unpack(args))
				end)
			)
		end
	end

	local close = function()
		if timer then
			timer:stop()
			if not timer:is_closing() then
				timer:close()
			end
			timer = nil
		end
	end

	return debounced, close
end

return M
