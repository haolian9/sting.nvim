local M = {}

local ex = require("infra.ex")
local jelly = require("infra.jellyfish")("sting.rhs")
local winsplit = require("infra.winsplit")

local api = vim.api

do
  ---@param side infra.winsplit.Sides
  function M.split(side)
    local pickle
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
        pickle = vim.fn.getloclist(0, { idx = held_idx, items = 0 }).items[1]
      elseif wininfo.quickfix == 1 then
        local held_idx = vim.fn.getqflist({ idx = 0 }).idx
        if held_idx < 1 then return jelly.debug("no lines in current location list") end
        if held_idx ~= expect_idx then
          vim.fn.setqflist({}, "a", { idx = expect_idx })
          held_idx = expect_idx
        end
        ---@type sting.Pickle
        pickle = vim.fn.getqflist({ idx = held_idx, items = 0 }).items[1]
      else
        jelly.err("winid=%d, wininfo=%s", winid, wininfo)
        error("supposed to be in a quickfix/location window")
      end
      assert(pickle.bufnr and pickle.lnum and pickle.col)
    end

    do
      ex("wincmd", "p")
      winsplit(side)
      local winid = api.nvim_get_current_win()
      api.nvim_win_set_buf(winid, pickle.bufnr)
      api.nvim_win_set_cursor(winid, { pickle.lnum, pickle.col - 1 })
    end
  end
end

return M
