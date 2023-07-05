local M = {}

local ex = require("infra.ex")
local jelly = require("infra.jellyfish")("sting.rhs", vim.log.levels.DEBUG)

local api = vim.api

do
  local splitcmds = {
    above = "aboveleft split",
    below = "belowright split",
    left = "aboveleft vsplit",
    right = "belowright vsplit",
  }

  local function split(mode, bufnr)
    ex("wincmd", "p")
    ex(assert(splitcmds[mode]))
    local winid = api.nvim_get_current_win()
    api.nvim_win_set_buf(winid, bufnr)
  end

  local function find_quickfix_current_bufnr()
    local curline = vim.fn.getqflist({ idx = 0 }).idx
    if curline < 1 then return jelly.debug("no lines in current quickfix list") end
    ---@type sting.Pickle
    local pickle = vim.fn.getqflist({ idx = curline, items = 0 }).items[1]
    return assert(pickle.bufnr)
  end

  local function find_location_current_bufnr()
    ---luckily, this magic winid=0 will be converted to lastwin
    local curline = vim.fn.getloclist(0, { idx = 0 }).idx
    if curline < 1 then return jelly.debug("no lines in current location list") end
    ---@type sting.Pickle
    local pickle = vim.fn.getloclist(0, { idx = curline, items = 0 }).items[1]
    return assert(pickle.bufnr)
  end

  ---@param mode 'above'|'below'|'left'|'right'
  function M.split(mode)
    local winid = api.nvim_get_current_win()
    local wininfo = vim.fn.getwininfo(winid)[1]
    local bufnr
    ---must check loclist first, as .quickfix=1 in both location and quickfix window
    if wininfo.loclist == 1 then
      bufnr = find_location_current_bufnr()
    elseif wininfo.quickfix == 1 then
      bufnr = find_quickfix_current_bufnr()
    else
      jelly.err("winid=%d, wininfo=%s", winid, vim.inspect(wininfo))
      error("supposed to be in a quickfix/location window")
    end
    if bufnr == nil then return end
    split(mode, bufnr)
  end
end

return M
