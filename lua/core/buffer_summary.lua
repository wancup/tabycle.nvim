local tab = require("core.tab")
local store = require("core.store")
local window = require("ui.window")

local M = {}

---@type boolean
local enabled = false

local ns_id = vim.api.nvim_create_namespace("tabycle-buffer-summary")

---@param is_current boolean
---@param cursor string
---@param width integer
local function cursor_icon(is_current, cursor, width)
	local cursor_width = vim.fn.strwidth(cursor)
	local placeholder = " "
	if is_current then
		return cursor .. string.rep(placeholder, width - cursor_width)
	else
		return string.rep(placeholder, width)
	end
end

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

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "", "" }) -- Add cursor line

	local sign_col_index = 0
	local cursor_col_index = 0
	for _, t in ipairs(tab_list) do
		local mark = t.modified and { icon = "*", hi_group = "Question" } or t.diagnostic_mark
		-- Sign Line
		local icon_len = #mark.icon
		local next_sign_col_index = sign_col_index + icon_len
		vim.api.nvim_buf_set_text(buf, 0, sign_col_index, 0, sign_col_index, { mark.icon })
		vim.api.nvim_buf_set_extmark(buf, ns_id, 0, sign_col_index, {
			hl_group = mark.hi_group,
			end_col = next_sign_col_index,
		})
		sign_col_index = next_sign_col_index

		-- Cursor Line
		local mark_width = vim.fn.strwidth(mark.icon)
		local cursor = cursor_icon(t.is_current, "^", mark_width)
		vim.api.nvim_buf_set_text(buf, 1, cursor_col_index, 1, cursor_col_index, { cursor })
		cursor_col_index = cursor_col_index + #cursor
	end
	vim.api.nvim_buf_set_extmark(buf, ns_id, 1, 0, { line_hl_group = "Comment" })

	---@type vim.api.keyset.win_config
	local win_config = {
		relative = "editor",
		width = sign_col_index,
		height = 2,
		row = 2,
		col = vim.o.columns - sign_col_index - 1,
		style = "minimal",
		border = "none",
		focusable = false,
	}

	if store.buffer_summary_win ~= nil then
		window.replace_with_bd(store.buffer_summary_win, buf, win_config)
	else
		store.buffer_summary_win = vim.api.nvim_open_win(buf, false, win_config)
	end
end

M.close = function()
	enabled = false

	if store.buffer_summary_win ~= nil then
		window.close_with_bd(store.buffer_summary_win)
		store.buffer_summary_win = nil
	end
end

M.toggle = function()
	if store.buffer_summary_win == nil then
		M.show()
	else
		M.close()
	end
end

return M
