local tab = require("core.tab")
local buf = require("core.buf")
local store = require("core.store")
local window = require("ui.window")

local M = {}

local buffer_list_ft = "tabycle-buffer-list"
local cycle_win_width_ratio = 0.8
local cycle_win_height_ratio = 0.8
local auto_confirming_ms = 1000

local progress_frames = {
	"tabycle:[----------]",
	"tabycle:[=---------]",
	"tabycle:[==--------]",
	"tabycle:[===-------]",
	"tabycle:[====------]",
	"tabycle:[=====-----]",
	"tabycle:[======----]",
	"tabycle:[=======---]",
	"tabycle:[========--]",
	"tabycle:[=========-]",
	"tabycle:[==========]",
}

---@type uv.uv_timer_t | nil
local confirmation_timer = nil

---@type uv.uv_timer_t | nil
local progress_timer = nil

---@type integer | nil
local selecting_buf = nil

---@type integer | nil
local source_buf = nil

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

---@param tab_list TabItem[]
local function select_cursor_buf(tab_list)
	local cursor_pos = vim.api.nvim_win_get_cursor(store.cycle_list_win)
	local selected_tab = tab_list[cursor_pos[1]]
	open_buf(selected_tab.bufnr)
	M.close()
end

local function show_cycle_progress()
	local frame_count = #progress_frames
	local progress_buf = vim.api.nvim_create_buf(false, true)
	store.cycle_progress_win = vim.api.nvim_open_win(progress_buf, false, {
		relative = "editor",
		width = #progress_frames[1],
		height = 1,
		row = 0,
		col = 0,
		style = "minimal",
		border = "rounded",
		focusable = false,
	})

	local interval = math.floor(auto_confirming_ms / frame_count)
	local timer, err = vim.loop.new_timer()
	if timer == nil then
		error(err)
	end
	progress_timer = timer

	local frame = 1
	progress_timer:start(
		0,
		interval,
		vim.schedule_wrap(function()
			if vim.api.nvim_buf_is_valid(progress_buf) then
				vim.api.nvim_buf_set_lines(progress_buf, 0, -1, false, { progress_frames[frame] })
			end
			frame = frame % frame_count + 1
		end)
	)
end

local function close_cycle_progress()
	if progress_timer ~= nil then
		progress_timer:stop()
		progress_timer:close()
		progress_timer = nil
	end
	if store.cycle_progress_win ~= nil then
		window.close_with_bd(store.cycle_progress_win)
		store.cycle_progress_win = nil
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
	vim.keymap.set("n", "<cr>", function()
		select_cursor_buf(tab_list)
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
	local base_buf = selecting_buf ~= nil and selecting_buf or vim.api.nvim_get_current_buf()
	local index = find_buf_index(tab_list, base_buf)
	if index == nil then
		return tab_list[1].bufnr
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
	if store.cycle_list_win == nil and not store.cycle_progress_win then
		working_win = vim.api.nvim_get_current_win()
	end
	local is_first_call = confirmation_timer == nil and selecting_buf == nil
	if is_first_call then
		-- Start accepting preview request
		source_buf = vim.api.nvim_get_current_buf()
		local tab_list = tab.get_recency_list()
		local target_buf = find_target_buf(tab_list, direction)
		open_buf(target_buf)
		confirmation_timer = vim.defer_fn(function()
			if confirmation_timer ~= nil then
				confirmation_timer = nil
			end
			close_cycle_progress()

			-- Since ignoring on BufEnter autocmd, manullay push
			tab.push_history(target_buf)
		end, auto_confirming_ms)
		show_cycle_progress()
	else
		close_cycle_progress()
		if confirmation_timer ~= nil then
			confirmation_timer:close()
			confirmation_timer = nil
		end

		-- Restore the state before Cycle
		if source_buf ~= nil then
			open_buf(source_buf)
			tab.push_history(source_buf)
			source_buf = nil
		end

		local tab_list = tab.get_recency_list()
		local target_buf = find_target_buf(tab_list, direction)
		show_preview(tab_list, target_buf)
		selecting_buf = target_buf
	end
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
	selecting_buf = nil
	if confirmation_timer ~= nil then
		confirmation_timer:close()
		confirmation_timer = nil
	end
end

return M
