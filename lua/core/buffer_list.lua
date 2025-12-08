local tab = require("core.tab")
local buf = require("core.buf")
local store = require("core.store")
local window = require("ui.window")

local M = {}

---@type boolean
local enabled = false

M.sync = function()
	if enabled == true then
		M.show()
	end
end

M.show = function()
	enabled = true

	local tab_list = tab.get_list()
	if #tab_list == 0 then
		return
	end

	local buffer_list = buf.make_buffer_list(tab_list, function(t)
		return t.is_current
	end)
	local row = math.floor(vim.o.lines - buffer_list.height - 3)
	local col = math.floor(vim.o.columns - buffer_list.width - 2)

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
