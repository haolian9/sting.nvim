local M = {}

local dictlib = require("infra.dictlib")

local types = require("sting.types")
local tui = require("tui")

local last_fed_name = nil

---@type {[string]: sting.Shelf}
local shelves = {}

local function Shelf(name)
  local shelf = types.Shelf(name)
  function shelf:feed_vim()
    ---@diagnostic disable: invisible
    if last_fed_name == self.name then return end
    vim.fn.setqflist({}, "f")
    vim.fn.setqflist(self.shelf, " ")
    last_fed_name = self.name
  end
  return shelf
end

---@param name string @the unique name for this shelf
---@return sting.Shelf
function M.shelf(name)
  if shelves[name] == nil then shelves[name] = Shelf(name) end
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
