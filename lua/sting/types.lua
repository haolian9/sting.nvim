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
  ---@class sting.Shelf
  ---@field private name string
  ---@field private shelf sting.Pickle[]
  local Prototype = {}

  Prototype.__index = Prototype

  function Prototype:reset() self.shelf = {} end

  function Prototype:append(pickle) table.insert(self.shelf, pickle) end

  ---@param list sting.Pickle[]
  function Prototype:extend(list) listlib.extend(self.shelf, list) end

  function Prototype:feed_vim() error("not implemented") end

  ---@param name string
  ---@return sting.Shelf
  function M.Shelf(name) return setmetatable({ name = name, list = {} }, Prototype) end
end

return M
