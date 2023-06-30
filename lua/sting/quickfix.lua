local M = {}

local dictlib = require("infra.dictlib")

local types = require("sting.types")
local tui = require("tui")

---@type {[string]: sting.Shelf}
local shelves = {}

---@param name string @the unique name for this shelf
---@return sting.Shelf
function M.shelf(name)
  if shelves[name] == nil then shelves[name] = types.Shelf(name) end
  return shelves[name]
end

function M.switch()
  tui.menu(dictlib.keys(shelves), { prompt = "switch quickfix shelves" }, function(name)
    if name == nil then return end
    M.shelf(name):feed_vim()
  end)
end

function M.clear() shelves = {} end

return M
