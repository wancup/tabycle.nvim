local M = {}

---@param tabycle table
function M.init(tabycle)
	---@type table<string, function>
	local commands = {
		["summary show"] = tabycle.show_summary,
		["summary close"] = tabycle.close_summary,
		["summary toggle"] = tabycle.toggle_summary,
		["list show"] = tabycle.show_list,
		["list close"] = tabycle.close_list,
		["list toggle"] = tabycle.toggle_list,
		["cycle back"] = tabycle.cycle_buffer_back,
		["cycle forward"] = tabycle.cycle_buffer_forward,
	}

	vim.api.nvim_create_user_command("Tabycle", function(cmd_opts)
		local key = table.concat(cmd_opts.fargs, " ")
		local fn = commands[key]
		if fn then
			fn()
		else
			vim.notify("Tabycle: unknown command '" .. key .. "'", vim.log.levels.ERROR)
		end
	end, {
		nargs = "+",
		complete = function(arg_lead, cmd_line)
			local input = cmd_line:gsub("^%s*Tabycle%s*", "")
			local parts = vim.split(input, "%s+", { trimempty = true })

			if #parts <= 1 and not input:match("%s$") then
				-- Complete group
				local groups = {}
				for key in pairs(commands) do
					local group = key:match("^(%S+)")
					groups[group] = true
				end
				return vim.tbl_filter(function(g)
					return vim.startswith(g, arg_lead)
				end, vim.tbl_keys(groups))
			else
				-- Complete action
				local group = parts[1]
				local actions = {}
				for key in pairs(commands) do
					local g, a = key:match("^(%S+)%s+(%S+)$")
					if g == group then
						actions[#actions + 1] = a
					end
				end
				return vim.tbl_filter(function(a)
					return vim.startswith(a, arg_lead)
				end, actions)
			end
		end,
	})
end

return M
