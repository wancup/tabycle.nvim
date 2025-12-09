local M = {}

---@class BufferList
---@field bufnr integer
---@field width integer
---@field height integer
---@field cursor_index integer | nil

local ns_id = vim.api.nvim_create_namespace("tabycle-buf")

---@param lines string[]
---@return integer
local function max_line_width(lines)
	local len = 0
	for _, line in ipairs(lines) do
		len = math.max(len, vim.fn.strwidth(line))
	end
	return len
end

---@param tab_list TabItem[]
---@param is_current fun(tab: TabItem): boolean
---@return BufferList
M.make_buffer_list = function(tab_list, is_current)
	---@type string[]
	local lines = {}

	---@type integer | nil
	local cursor_index = nil

	for i, t in ipairs(tab_list) do
		local _is_current = is_current(t)
		local prefix = _is_current and ">" or " "
		local modified_mark = t.modified and "*" or ""
		local line = string.format("%s %s%s", prefix, t.short_name, modified_mark)
		table.insert(lines, line)
		if _is_current then
			cursor_index = i
		end
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	for i, t in ipairs(tab_list) do
		if not t.in_window then
			vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, 0, {
				line_hl_group = "Comment",
			})
		end
		if t.modified then
			local line = lines[i]
			vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, #line - 1, {
				hl_group = "Question",
				end_col = #line,
			})
		end
	end

	---@type BufferList
	return {
		bufnr = buf,
		width = max_line_width(lines),
		height = #lines,
		cursor_index = cursor_index,
	}
end

return M
