local tab = require("core.tab")
local store = require("core.store")
local buffer_summary = require("core.buffer_summary")
local buffer_list = require("core.buffer_list")
local debounce = require("utils.debounce")

local M = {}

local augroup = vim.api.nvim_create_augroup("Tabycle", { clear = true })

local sync_ui = debounce.debounce(function()
	tab.clear_cache()
	buffer_summary.sync()
	buffer_list.sync()
end, 100)

---@param bufnr integer
---@return boolean
local function should_fire_event(bufnr)
	return not store.is_own_buf(bufnr) and vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_name(bufnr) ~= ""
end

M.init = function()
	vim.api.nvim_create_autocmd({
		"BufEnter",
	}, {
		group = augroup,
		callback = function(param)
			vim.schedule(function()
				if should_fire_event(param.buf) then
					tab.push_history(param.buf)
					sync_ui()
				end
			end)
		end,
	})

	vim.api.nvim_create_autocmd({
		"BufDelete",
		"BufModifiedSet",
		"DiagnosticChanged",
		"ColorScheme",
	}, {
		group = augroup,
		callback = function(param)
			vim.schedule(function()
				if should_fire_event(param.buf) then
					sync_ui()
				end
			end)
		end,
	})
end

return M
