local M = {}

---@param win_id integer
---@param bufnr integer
---@param config vim.api.keyset.win_config
M.replace_with_bd = function(win_id, bufnr, config)
	local oldbuf = vim.api.nvim_win_get_buf(win_id)
	vim.api.nvim_win_set_buf(win_id, bufnr)
	vim.api.nvim_win_set_config(win_id, config)
	vim.api.nvim_buf_delete(oldbuf, {})
end

---@param win_id integer
M.close_with_bd = function(win_id)
	local bufnr = vim.api.nvim_win_get_buf(win_id)
	vim.api.nvim_win_close(win_id, true)
	vim.api.nvim_buf_delete(bufnr, {})
end

---@param win_id integer
---@return boolean
M.is_floating = function(win_id)
	local config = vim.api.nvim_win_get_config(win_id)
	if config.relative ~= "" then
		return true
	end
	return false
end

return M
