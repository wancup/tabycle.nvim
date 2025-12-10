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
M.is_own_buf = function(bufnr)
	local all = {
		M.buffer_list_win,
		M.buffer_summary_win,
		M.cycle_list_win,
		M.cycle_preview_win,
		M.cycle_progress_win,
	}
	for _, win in pairs(all) do
		if win ~= nil and vim.api.nvim_win_get_buf(win) == bufnr then
			return true
		end
	end
	return false
end

return M
