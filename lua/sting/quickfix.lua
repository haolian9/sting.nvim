local M = {}

local dictlib = require("infra.dictlib")

local types = require("sting.types")
local tui = require("tui")

local last_fed_name = nil

---@type {[string]: sting.Shelf}
local shelves = {}

local Shelf
do
  ---@param name string
  function Shelf(name)
    local shelf = types.Shelf(name, true)
    function shelf:feed_vim()
      ---@diagnostic disable: invisible

      --qflist has been set outside sting
      if vim.fn.getqflist({ title = 1 }).title == last_fed_name then
        if last_fed_name == self.name then return end
      end

      do
        vim.fn.setqflist({}, "f")
        if self.flavor == nil then
          vim.fn.setqflist(self.shelf, " ", { title = self.name })
        else
          vim.fn.setqflist({}, " ", {
            title = self.name,
            items = self.shelf,
            quickfixtextfunc = function(...) return self:quickfixtextfunc(...) end,
          })
        end
      end
      last_fed_name = self.name
    end
    return shelf
  end
end

---@param name string @the unique name for this shelf
---@return sting.Shelf
function M.shelf(name)
  if shelves[name] == nil then shelves[name] = Shelf(name) end
  return shelves[name]
end

function M.switch()
  tui.select(dictlib.keys(shelves), { prompt = "switch quickfix shelves" }, function(name)
    if name == nil then return end
    M.shelf(name):feed_vim()
  end)
end

function M.clear() shelves = {} end

return M
