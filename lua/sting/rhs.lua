local M = {}

local ex = require("infra.ex")
local jelly = require("infra.jellyfish")("sting.rhs")

local api = vim.api

do
  local splitcmds = {
    above = "aboveleft split",
    below = "belowright split",
    left = "aboveleft vsplit",
    right = "belowright vsplit",
  }

  ---@param mode 'above'|'below'|'left'|'right'
  function M.split(mode)
    local bufnr
    do
      local winid = api.nvim_get_current_win()
      local wininfo = vim.fn.getwininfo(winid)[1]
      local expect_idx = api.nvim_win_get_cursor(winid)[1]
      ---must check loclist first, as .quickfix=1 in both location and quickfix window
      if wininfo.loclist == 1 then
        local held_idx = vim.fn.getloclist(0, { idx = 0 }).idx
        if held_idx < 1 then return jelly.debug("no lines in current quickfix list") end
        if held_idx ~= expect_idx then
          vim.fn.setloclist(winid, {}, "a", { idx = expect_idx })
          held_idx = expect_idx
        end
        ---@type sting.Pickle
        local pickle = vim.fn.getloclist(0, { idx = held_idx, items = 0 }).items[1]
        bufnr = assert(pickle.bufnr)
      elseif wininfo.quickfix == 1 then
        local held_idx = vim.fn.getqflist({ idx = 0 }).idx
        if held_idx < 1 then return jelly.debug("no lines in current location list") end
        if held_idx ~= expect_idx then
          vim.fn.setqflist({}, "a", { idx = expect_idx })
          held_idx = expect_idx
        end
        ---@type sting.Pickle
        local pickle = vim.fn.getqflist({ idx = held_idx, items = 0 }).items[1]
        bufnr = assert(pickle.bufnr)
      else
        jelly.err("winid=%d, wininfo=%s", winid, vim.inspect(wininfo))
        error("supposed to be in a quickfix/location window")
      end
      assert(bufnr ~= nil)
    end

    do
      ex("wincmd", "p")
      ex(assert(splitcmds[mode]))
      local winid = api.nvim_get_current_win()
      api.nvim_win_set_buf(winid, bufnr)
    end
  end
end

return M
