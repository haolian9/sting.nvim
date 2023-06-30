--- the names, pickle and shelf, come from python, which are its stdlibs

local M = {}

local listlib = require("infra.listlib")

---@class sting.Pickle
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

do
  ---it's intended to no having append()
  ---@class sting.Shelf
  ---@field private name string
  ---@field private list sting.Pickle[]
  local Prototype = {}

  Prototype.__index = Prototype

  function Prototype:reset() self.list = {} end

  ---@param list sting.Pickle[]
  function Prototype:extend(list) listlib.extend(self.list, list) end

  function Prototype:feed_vim()
    vim.fn.setqflist({}, "f")
    vim.fn.setqflist(self.list, " ")
  end

  function M.Shelf(name) return setmetatable({ name = name, list = {} }, Prototype) end
end

return M
