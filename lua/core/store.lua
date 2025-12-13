local M = {}

---@type integer | nil
M.buffer_list_win = nil

---@type integer | nil
M.buffer_summary_win = nil

---@type integer | nil
M.cycle_list_win = nil

---@type integer | nil
M.cycle_preview_win = nil

---@type integer | nil
M.cycle_progress_win = nil

---@param bufnr integer
---@return boolean
function M.is_own_buf(bufnr)
	local fin_fields = {
		"buffer_list_win",
		"buffer_summary_win",
		"cycle_list_win",
		"cycle_preview_win",
		"cycle_progress_win",
	}
	for _, field in pairs(fin_fields) do
		local win = M[field]
		if win == nil then
			goto continue
		end
		if not vim.api.nvim_win_is_valid(win) then
			M[field] = nil
			goto continue
		end
		if vim.api.nvim_win_get_buf(win) == bufnr then
			return true
		end
		::continue::
	end
	return false
end

return M
