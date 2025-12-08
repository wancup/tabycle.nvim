local tab = require("core.tab")
local buf = require("core.buf")
local store = require("core.store")
local window = require("ui.window")

local M = {}

local buffer_list_ft = "tabycle-buffer-list"
local cycle_win_width_ratio = 0.8
local cycle_win_height_ratio = 0.8

---@type integer | nil
local current_buf = nil

---@type integer| nil
local working_win = nil

---@param bufnr integer
local function open_buf(bufnr)
	local windows = vim.fn.win_findbuf(bufnr)

	---@type integer | nil
	local exist_win = nil
	for _, win in ipairs(windows) do
		if win ~= store.cycle_preview_win then
			exist_win = win
		end
	end

	if exist_win ~= nil then
		vim.api.nvim_set_current_win(exist_win)
	elseif working_win ~= nil then
		vim.api.nvim_win_set_buf(working_win, bufnr)
	end
end

---@param buffer_list BufferList
---@param tab_list TabItem[]
local function show_buffer_list(buffer_list, tab_list)
	local row = math.floor((vim.o.lines - buffer_list.height) / 2)
	local whole_width = math.floor(vim.o.columns * cycle_win_width_ratio)
	local col = math.floor((vim.o.columns - whole_width) / 2)
	local max_height = math.floor(vim.o.lines * cycle_win_height_ratio)

	---@type vim.api.keyset.win_config
	local win_config = {
		relative = "editor",
		width = buffer_list.width,
		height = math.min(buffer_list.height, max_height),
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}
	if store.cycle_list_win ~= nil then
		window.replace_with_bd(store.cycle_list_win, buffer_list.bufnr, win_config)
	else
		store.cycle_list_win = vim.api.nvim_open_win(buffer_list.bufnr, true, win_config)
	end

	vim.api.nvim_set_option_value("modifiable", false, { buf = buffer_list.bufnr })
	vim.api.nvim_set_option_value("filetype", buffer_list_ft, { buf = buffer_list.bufnr })
	vim.keymap.set("n", "q", M.close, { buffer = buffer_list.bufnr, noremap = true, silent = true })
	vim.keymap.set("n", "<esc>", M.close, { buffer = buffer_list.bufnr, noremap = true, silent = true })
	vim.keymap.set("n", "<cr>", function()
		local cursor_pos = vim.api.nvim_win_get_cursor(store.cycle_list_win)
		local selected_tab = tab_list[cursor_pos[1]]
		open_buf(selected_tab.bufnr)
		M.close()
	end, { buffer = buffer_list.bufnr, noremap = true, silent = true })

	if buffer_list.cursor_index ~= nil then
		vim.api.nvim_win_set_cursor(store.cycle_list_win, { buffer_list.cursor_index, 0 })
	end
end

---@param bufnr integer
local function show_buffer_preview(bufnr)
	local win_gap = 2
	local list_win = store.cycle_list_win ~= nil and vim.api.nvim_win_get_config(store.cycle_list_win) or nil
	local list_width = list_win ~= nil and list_win.width or 0
	local height = math.floor(vim.o.lines * cycle_win_height_ratio)
	local width = math.floor((vim.o.columns * cycle_win_width_ratio) - list_width - win_gap)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = list_win ~= nil and list_win.col + list_win.width + win_gap or math.floor((vim.o.columns - width) / 2)
	local bufname = vim.fn.bufname(bufnr)
	local title = vim.fn.fnamemodify(bufname, ":p:.")

	---@type vim.api.keyset.win_config
	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		focusable = false,
		title = { { title, "Comment" } },
		title_pos = "center",
	}
	if store.cycle_preview_win ~= nil then
		vim.api.nvim_win_set_buf(store.cycle_preview_win, bufnr)
		vim.api.nvim_win_set_config(store.cycle_preview_win, win_config)
	else
		store.cycle_preview_win = vim.api.nvim_open_win(bufnr, false, win_config)
	end
end

---@param tab_list TabItem[]
---@param target_buf integer
local function show_preview(tab_list, target_buf)
	local buffer_list = buf.make_buffer_list(tab_list, function(t)
		return t.bufnr == target_buf
	end)
	show_buffer_list(buffer_list, tab_list)
	show_buffer_preview(target_buf)
end

---@param tab_list TabItem[]
---@param bufnr integer
---@return integer | nil
local function find_buf_index(tab_list, bufnr)
	for i, t in ipairs(tab_list) do
		if t.bufnr == bufnr then
			return i
		end
	end
	return nil
end

---@param tab_list TabItem[]
---@param direction "prev" | "next"
---@return integer
local function find_target_buf(tab_list, direction)
	local base_buf = current_buf ~= nil and current_buf or vim.api.nvim_get_current_buf()
	local index = find_buf_index(tab_list, base_buf)
	if index == nil then
		return base_buf
	end

	if direction == "prev" then
		if index >= #tab_list then
			return tab_list[1].bufnr
		else
			return tab_list[index + 1].bufnr
		end
	end

	if index <= 1 then
		return tab_list[#tab_list].bufnr
	else
		return tab_list[index - 1].bufnr
	end
end

---@param direction "prev" | "next"
local function cycle_buffer(direction)
	if store.cycle_list_win == nil then
		working_win = vim.api.nvim_get_current_win()
	end
	local tab_list = tab.get_recency_list()
	local target_buf = find_target_buf(tab_list, direction)
	show_preview(tab_list, target_buf)
	current_buf = target_buf
end

M.cycle_back = function()
	cycle_buffer("prev")
end

M.cycle_forward = function()
	cycle_buffer("next")
end

M.close = function()
	if store.cycle_list_win ~= nil then
		window.close_with_bd(store.cycle_list_win)
		store.cycle_list_win = nil
	end
	if store.cycle_preview_win ~= nil then
		vim.api.nvim_win_close(store.cycle_preview_win, true)
		store.cycle_preview_win = nil
	end
	current_buf = nil
end

return M
