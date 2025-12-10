local window = require("ui.window")

local M = {}

---@class DiagnosticInfo
---@field list_icon string
---@field summary_icon string
---@field severity vim.diagnostic.SeverityInt | nil
---@field hi_group string

---@class TabItem
---@field bufnr integer
---@field short_name string
---@field is_current boolean
---@field modified boolean
---@field in_window boolean
---@field diagnostic DiagnosticInfo

local max_history = 100

---@type integer[]
local history = {}

---@param bufnr integer
---@return DiagnosticInfo
local function get_diagnostic_mark(bufnr)
	local diagnostics = vim.diagnostic.get(bufnr)

	if #diagnostics == 0 then
		---@type DiagnosticInfo
		return {
			list_icon = "",
			summary_icon = ".",
			severity = nil,
			hi_group = "Comment",
		}
	end

	local top_severity = vim.diagnostic.severity.HINT
	for _, d in ipairs(diagnostics) do
		if d.severity < top_severity then
			top_severity = d.severity --[[@as vim.diagnostic.SeverityInt]]
		end
	end

	local severity_initial = string.sub(vim.diagnostic.severity[top_severity], 1, 1)
	---@type DiagnosticInfo
	return {
		list_icon = string.format("[%s]", severity_initial),
		summary_icon = severity_initial,
		severity = top_severity,
		hi_group = "DiagnosticSign" .. vim.diagnostic.severity[top_severity],
	}
end

---@param bufnr integer
---@return integer | nil
local function get_buf_priority(bufnr)
	for i = #history, 1, -1 do
		if history[i] == bufnr then
			return #history - i + 1
		end
	end
	return nil
end

---@param list TabItem[]
local function sort_by_recency(list)
	table.sort(list, function(a, b)
		local a_priority = get_buf_priority(a.bufnr)
		local b_priority = get_buf_priority(b.bufnr)
		if a_priority == nil and b_priority == nil then
			return false
		elseif a_priority == nil and b_priority ~= nil then
			return false
		elseif a_priority ~= nil and b_priority == nil then
			return true
		else
			return a_priority < b_priority
		end
	end)
end

---@param bufnr integer
M.push_history = function(bufnr)
	local latest = history[#history]
	if bufnr == latest then
		return
	end

	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	local bufname = vim.api.nvim_buf_get_name(bufnr)
	if bufname == "" then
		return
	end

	if #history > max_history then
		table.remove(history, 1)
	end

	table.insert(history, bufnr)
end

---@param bufnr integer
local function is_buf_in_window(bufnr)
	local win_ids = vim.fn.win_findbuf(bufnr)
	for _, win in ipairs(win_ids) do
		if not window.is_floating(win) then
			return true
		end
	end
	return false
end

---@return TabItem[]
M.get_list = function()
	---@type TabItem[]
	local tab_list = {}

	local buffers = vim.api.nvim_list_bufs()
	local current_buf = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(buffers) do
		if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].buflisted then
			goto continue
		end

		local full_path = vim.api.nvim_buf_get_name(buf)
		local diagnostic_mark = get_diagnostic_mark(buf)
		if full_path ~= "" then
			---@type TabItem
			local item = {
				bufnr = buf,
				long_name = vim.fn.fnamemodify(full_path, ":p:."),
				short_name = vim.fn.fnamemodify(full_path, ":t"),
				is_current = buf == current_buf,
				modified = vim.bo[buf].modified,
				in_window = is_buf_in_window(buf),
				diagnostic = diagnostic_mark,
			}
			table.insert(tab_list, item)
		end

		::continue::
	end

	return tab_list
end

---@return TabItem[]
M.get_recency_list = function()
	local _list = M.get_list()
	local tab_list = vim.deepcopy(_list)
	sort_by_recency(tab_list)
	return tab_list
end

return M
