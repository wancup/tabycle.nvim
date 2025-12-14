local config = require("core.config")
local tab = require("core.tab")
local buf = require("core.buf")
local store = require("core.store")
local window = require("ui.window")

local M = {}

---@type boolean
local enabled = false

---@param tab_list TabItem[] | nil
---@return TabItem[] | nil
function M.sync(tab_list)
	if enabled == true then
		return M.show(tab_list)
	end
	return nil
end

---@param tab_list TabItem[] | nil
---@return TabItem[] | nil
function M.show(tab_list)
	enabled = true
	if tab_list ~= nil and #tab_list == 0 then
		return
	end

	local list = tab_list ~= nil and tab_list or tab.get_list()
	if #list == 0 then
		return nil
	end

	local buffer_list = buf.make_buffer_list(list, config.options.list.cursor_icon)
	local pos = config.options.list.position
	local row = window.resolve_position(pos.row, vim.o.lines, buffer_list.height)
	local col = window.resolve_position(pos.col, vim.o.columns, buffer_list.width)

	---@type vim.api.keyset.win_config
	local win_config = {
		relative = "editor",
		width = buffer_list.width,
		height = buffer_list.height,
		row = row,
		col = col,
		style = "minimal",
		border = config.options.list.border,
		focusable = false,
	}
	if store.buffer_list_win ~= nil then
		window.replace_with_bd(store.buffer_list_win, buffer_list.bufnr, win_config)
	else
		store.buffer_list_win = vim.api.nvim_open_win(buffer_list.bufnr, false, win_config)
	end
	return list
end

function M.close()
	enabled = false

	if store.buffer_list_win ~= nil then
		window.close_with_bd(store.buffer_list_win)
		store.buffer_list_win = nil
	end
end

function M.toggle()
	if store.buffer_list_win == nil then
		M.show()
	else
		M.close()
	end
end

return M
