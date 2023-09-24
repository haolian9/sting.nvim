local M = {}

local dictlib = require("infra.dictlib")
local ex = require("infra.ex")

local toggle = require("sting.toggle")
local types = require("sting.types")
local puff = require("puff")

---@type {[string]: sting.Shelf}
local shelves = {}

---@param name string
local function Shelf(name)
  local shelf = types.Shelf(name, true)

  function shelf:feed_vim(open_win, goto_first)
    ---@diagnostic disable: invisible
    vim.fn.setqflist({}, "f")
    if self.flavor == nil then
      vim.fn.setqflist(self.shelf, " ", { title = self.name })
    else
      vim.fn.setqflist({}, " ", { title = self.name, items = self.shelf, quickfixtextfunc = function(...) return self:quickfixtextfunc(...) end })
    end

    if not open_win then return end
    toggle.open_qfwin()

    if not goto_first then return end
    ex("cc 1")
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
  puff.select(dictlib.keys(shelves), { prompt = "switch quickfix shelves" }, function(name)
    if name == nil then return end
    M.shelf(name):feed_vim(true, false)
  end)
end

function M.clear() shelves = {} end

return M
