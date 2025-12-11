local M = {}

---@class BufferList
---@field bufnr integer
---@field width integer
---@field height integer

local ns_id = vim.api.nvim_create_namespace("tabycle-buf")

---@param tab_list TabItem[]
---@param cursor_icon string | nil
---@return BufferList
M.make_buffer_list = function(tab_list, cursor_icon)
	---@type string[]
	local lines = {}

	local cursor_prefix = cursor_icon ~= nil and cursor_icon .. " " or ""
	local cursor_placeholder = string.rep(" ", vim.fn.strwidth(cursor_prefix))
	local max_width = 0

	for _ = 1, #tab_list do
		table.insert(lines, "")
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	for i, t in ipairs(tab_list) do
		local prefix = t.is_current and cursor_prefix or cursor_placeholder
		local diagnostic_mark = t.diagnostic.severity ~= nil and t.diagnostic.list_icon or ""
		local modified_mark = t.modified and "*" or ""
		local line = string.format("%s%s%s%s", prefix, t.short_name, modified_mark, diagnostic_mark)
		vim.api.nvim_buf_set_text(buf, i - 1, 0, i - 1, 0, { line })

		local line_width = vim.fn.strwidth(line)
		if line_width > max_width then
			max_width = line_width
		end

		-- Set highlight group
		local modified_mark_width = vim.fn.strwidth(modified_mark)
		local diagnostic_mark_width = vim.fn.strwidth(diagnostic_mark)
		if not t.in_window then
			vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, 0, {
				hl_group = "Comment",
				end_col = line_width,
			})
		end
		if t.diagnostic.severity ~= nil then
			vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, line_width - diagnostic_mark_width, {
				hl_group = t.diagnostic.hi_group,
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
	}
end

return M
