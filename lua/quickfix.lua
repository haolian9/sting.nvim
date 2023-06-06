-- available apis:
-- * switch current list: :colder, :cnewer
-- * :copen
-- * quickfix stack: :chistory
-- * QuickfixCmdPost, QuickfixCmdPre
-- * :cfile
--
--
-- * unique key, title, items
--
-- no stack: setqflist({}, 'f')
-- compatible entity struct
--   * bufnr or filename
--   * lnum, end_lnum, col, end_col
--   * text, type=enum{E, W, N}
--   * module="", vcol=1, pattern="", nr=1
--
-- todo:
-- * make use of quickfix stack to avoid massive data copying
--

local M = {}

local jelly = require("infra.jellyfish")("sting.quickfix", vim.log.levels.DEBUG)
local listlib = require("infra.listlib")

local state = {
  ---@type {[string]: {items: any[]}} @{namespace: {items: [any]}}
  store = {},
}

do -- setup
  -- todo: hijack setqflist outside sting.quickfix
end

---@param ns string @namespace
---@param items any[]
function M.set(ns, items)
  if state.store[ns] == nil then
    state.store[ns] = { items = items }
  else
    state.store[ns].items = items
  end
end

---@param ns string @namespace
---@param items any[]
function M.append(ns, items)
  if state.store[ns] == nil then
    state.store[ns] = { items = items }
  else
    listlib.extend(state.store[ns].items, items)
  end
end

---@param ns string @namespace
function M.feed_vim(ns)
  if state.store[ns] == nil then return jelly.warn("no such namespace %s", ns) end
  -- 'f' to clear the whole quickfix stack
  vim.fn.setqflist({}, "f")
  vim.fn.setqflist({}, " ", { items = state.store[ns].items })
end

function M.switch()
  -- todo: vim.ui.select
  -- local tui_menu = require("tui.menu")
end

function M.history()
  -- todo: show in floatwin
  -- columns: ns, items count, time
end

return M
