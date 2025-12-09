local M = {}

---@class BufferList
---@field bufnr integer
---@field width integer
---@field height integer
---@field cursor_index integer | nil

local ns_id = vim.api.nvim_create_namespace("tabycle-buf")

---@param tab_list TabItem[]
---@param is_current fun(tab: TabItem): boolean
---@return BufferList
M.make_buffer_list = function(tab_list, is_current)
	---@type string[]
	local lines = {}

	---@type integer | nil
	local cursor_index = nil

	local max_width = 0

	for _ = 1, #tab_list do
		table.insert(lines, "")
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	for i, t in ipairs(tab_list) do
		local _is_current = is_current(t)
		local prefix = _is_current and ">" or " "
		local diagnostic_mark = t.diagnostic_mark.severity ~= nil and t.diagnostic_mark.list_icon or ""
		local modified_mark = t.modified and "*" or ""
		local line = string.format("%s %s%s%s", prefix, t.short_name, modified_mark, diagnostic_mark)
		vim.api.nvim_buf_set_text(buf, i - 1, 0, i - 1, 0, { line })

		local line_width = vim.fn.strwidth(line)
		if line_width > max_width then
			max_width = line_width
		end

		-- Set highlight group
		local modified_mark_width = vim.fn.strwidth(modified_mark)
		local diagnostic_mark_width = vim.fn.strwidth(diagnostic_mark)
		if _is_current then
			cursor_index = i
		end
		if not t.in_window then
			vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, 0, {
				hl_group = "Comment",
				end_col = line_width,
			})
		end
		if t.diagnostic_mark.severity ~= nil then
			vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, line_width - diagnostic_mark_width, {
				hl_group = t.diagnostic_mark.hi_group,
				end_col = line_width,
			})
		end
		if t.modified then
			vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, line_width - modified_mark_width - diagnostic_mark_width, {
				hl_group = "Question",
				end_col = line_width - diagnostic_mark_width,
			})
		end
	end

	---@type BufferList
	return {
		bufnr = buf,
		width = max_width,
		height = #lines,
		cursor_index = cursor_index,
	}
end

return M
