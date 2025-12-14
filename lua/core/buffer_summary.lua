local config = require("core.config")
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
		return
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "", "" }) -- Add cursor line

	local sign_col_index = 0
	local cursor_col_index = 0
	for _, t in ipairs(list) do
		local mark = t.modified and { summary_icon = config.options.summary.modified_icon, hi_group = "Question" }
			or t.diagnostic
		-- Sign Line
		local icon_len = #mark.summary_icon
		local next_sign_col_index = sign_col_index + icon_len
		vim.api.nvim_buf_set_text(buf, 0, sign_col_index, 0, sign_col_index, { mark.summary_icon })
		vim.api.nvim_buf_set_extmark(buf, ns_id, 0, sign_col_index, {
			hl_group = mark.hi_group,
			end_col = next_sign_col_index,
		})
		sign_col_index = next_sign_col_index

		-- Cursor Line
		local mark_width = vim.fn.strwidth(mark.summary_icon)
		local cursor = cursor_icon(t.is_current, config.options.summary.cursor_icon, mark_width)
		vim.api.nvim_buf_set_text(buf, 1, cursor_col_index, 1, cursor_col_index, { cursor })
		cursor_col_index = cursor_col_index + #cursor
	end
	vim.api.nvim_buf_set_extmark(buf, ns_id, 1, 0, { line_hl_group = "Comment" })

	local win_opt = config.options.summary.win
	local row = window.resolve_position(win_opt.row, vim.o.lines, 2)
	local col = window.resolve_position(win_opt.col, vim.o.columns, sign_col_index)

	---@type vim.api.keyset.win_config
	local win_config = {
		relative = "editor",
		width = sign_col_index,
		height = 2,
		row = row,
		col = col,
		style = "minimal",
		border = win_opt.border,
		focusable = false,
	}

	if store.buffer_summary_win ~= nil then
		window.replace_with_bd(store.buffer_summary_win, buf, win_config)
	else
		store.buffer_summary_win = vim.api.nvim_open_win(buf, false, win_config)
	end

	return list
end

function M.close()
	enabled = false

	if store.buffer_summary_win ~= nil then
		window.close_with_bd(store.buffer_summary_win)
		store.buffer_summary_win = nil
	end
end

function M.toggle()
	if store.buffer_summary_win == nil then
		M.show()
	else
		M.close()
	end
end

return M
