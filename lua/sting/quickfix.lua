local M = {}

local jelly = require("infra.jellyfish")("sting.quickfix", vim.log.levels.DEBUG)
local tui = require("tui")
local unsafe = require("sting.unsafe")
local dictlib = require("infra.dictlib")
local fn = require("infra.fn")

---@class sting.quickfix.Namespace
---@field private ns string
---@field private lists clist[]
local Namespace = {}
do
  Namespace.__index = Namespace

  function Namespace:reset()
    local lists = self.lists
    self.lists = {}
    ---todo: figure out how the GC works
    for _, list in ipairs(lists) do
      unsafe.lists.free(list)
    end
  end

  function Namespace:extend(list)
    assert(#list > 0)
    local clist = unsafe.lists.alloc(#list)
    for _, item in ipairs(list) do
      local cdict = unsafe.dicts.alloc()
      for k, v in pairs(item) do
        unsafe.dicts.add(cdict, k, v)
      end
      unsafe.lists.append_dict(clist, cdict)
    end
    table.insert(self.lists, clist)
  end

  function Namespace:feed_vim()
    unsafe.quickfix.clear_stack()
    local iter = fn.iter(self.lists)
    unsafe.quickfix.new(iter(), self.ns)
    for clist in iter do
      unsafe.quickfix.extend(clist)
    end
  end

  function Namespace.new(ns) return setmetatable({ ns = ns, lists = {} }, Namespace) end
end

---@type {[string]: sting.quickfix.Namespace}
local registry = {}

---@param ns string
---@return sting.quickfix.Namespace
function M.namespace(ns)
  if registry[ns] == nil then registry[ns] = Namespace.new(ns) end
  return registry[ns]
end

function M.switch()
  tui.menu(dictlib.keys(registry), { prompt = "switch quickfix namespace" }, function(ns)
    if ns == nil then return end
    M.namespace(ns):feed_vim()
  end)
end

return M
