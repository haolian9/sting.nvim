local listlib = require("infra.listlib")

---@class sting.Item
---@field bufnr? number
---@field filename? string
---@field module? string
---@field lnum number
---@field end_lnum? number
---@field col number
---@field end_col? number
---@field vcol 0|1
---@field text string
---@field type 'E'|'W'|'N'
---@field pattern string
---@field nr number
---@field valid 0|1

---@class sting.Items
---@field private store {[string]: sting.Item[]}
local Items = {}
do
  Items.__index = Items

  function Items:get(ns) return self.store[ns] end

  function Items:clear(ns) self.store[ns] = nil end

  ---@param items sting.Item[]
  function Items:set(ns, items) self.store[ns] = items end

  ---@param item sting.Item
  function Items:append(ns, item)
    if self.store[ns] == nil then
      self.store[ns] = { item }
    else
      table.insert(self.store[ns], item)
    end
  end

  ---@param items sting.Item[]
  function Items:extend(ns, items)
    if self.store[ns] == nil then
      self.store[ns] = items
    else
      listlib.extend(self.store[ns], items)
    end
  end

  function Items:namespaces()
    local list = {}
    for key, _ in pairs(self.store) do
      table.insert(list, key)
    end
    return list
  end
end

return {
  ---@param store? table
  ---@return sting.Items
  Items = function(store)
    store = store or {}
    return setmetatable({ store = {} }, Items)
  end,
}
