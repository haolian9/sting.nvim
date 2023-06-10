---@class sting.Item
---@field bufnr? number
---@field filename? string
---@field module? string
---@field lnum number
---@field end_lnum number
---@field col number
---@field end_col number
---@field vcol 0|1
---@field text string
---@field type 'E'|'W'|'N'
---@field pattern string
---@field nr number
---@field valid 0|1

local M = {}

local jelly = require("infra.jellyfish")("sting.quickfix", vim.log.levels.DEBUG)
local listlib = require("infra.listlib")
local tui = require("tui")

do
  ---@type {[string]: sting.Item[]}
  local store = {}

  M.items = {
    get = function(ns) return store[ns] end,
    clear = function(ns) store[ns] = nil end,
    ---@param items sting.Item[]
    set = function(ns, items) store[ns] = items end,
    ---@param item sting.Item
    append = function(ns, item)
      if store[ns] == nil then
        store[ns] = { item }
      else
        table.insert(store[ns], item)
      end
    end,
    ---@param items sting.Item[]
    extend = function(ns, items)
      if store[ns] == nil then
        store[ns] = items
      else
        listlib.extend(store[ns], items)
      end
    end,
    namespaces = function()
      local list = {}
      for key, _ in pairs(store) do
        table.insert(list, key)
      end
      return list
    end,
  }
end

--caution: the quickfix stack will be cleared after this function
---@param ns string
---@return true?
function M.feed_vim(ns)
  local items = M.items.get(ns)
  if items == nil then return jelly.warn("no qf items under namespace '%s'", ns) end
  vim.fn.setqflist({}, "f") -- intended to clear the whole quickfix stack
  vim.fn.setqflist({}, " ", { items = items })
end

function M.switch()
  tui.menu(M.items.namespaces(), { prompt = "switch quickfix namespace" }, function(entry)
    if entry == nil then return end
    M.feed_vim(entry)
  end)
end

return M
