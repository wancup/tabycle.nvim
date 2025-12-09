local tab = require("core.tab")
local buf = require("core.buf")
local store = require("core.store")
local window = require("ui.window")

local M = {}

---@type boolean
local enabled = false

---@param tab_list TabItem[] | nil
---@return TabItem[] | nil
M.sync = function(tab_list)
	if enabled == true then
		return M.show(tab_list)
	end
	return nil
end

---@param tab_list TabItem[] | nil
---@return TabItem[] | nil
M.show = function(tab_list)
	enabled = true
	if tab_list ~= nil and #tab_list == 0 then
		return
	end

	local list = tab_list ~= nil and tab_list or tab.get_list()
	if #list == 0 then
		return nil
	end

	local buffer_list = buf.make_buffer_list(list, function(t)
		return t.is_current
	end)
	local row = math.floor(vim.o.lines - buffer_list.height - 3)
	local col = math.floor(vim.o.columns - buffer_list.width - 3)

	---@type vim.api.keyset.win_config
	local win_config = {
		relative = "editor",
		width = buffer_list.width,
		height = buffer_list.height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		focusable = false,
	}
	if store.buffer_list_win ~= nil then
		window.replace_with_bd(store.buffer_list_win, buffer_list.bufnr, win_config)
	else
		store.buffer_list_win = vim.api.nvim_open_win(buffer_list.bufnr, false, win_config)
	end
	return list
end

M.close = function()
	enabled = false

	if store.buffer_list_win ~= nil then
		window.close_with_bd(store.buffer_list_win)
		store.buffer_list_win = nil
	end
end

M.toggle = function()
	if store.buffer_list_win == nil then
		M.show()
	else
		M.close()
	end
end

return M
