--- the names, pickle and shelf, come from python, which are its stdlibs

local M = {}

local fn = require("infra.fn")
local fs = require("infra.fs")
local listlib = require("infra.listlib")
local strlib = require("infra.strlib")

---@class sting.Pickle
---@field bufnr? number
---@field filename? string
---@field module? string
---@field lnum number
---@field end_lnum? number
---@field col number
---@field end_col? number
---@field vcol? 0|1
---@field text string
---@field type? 'E'|'W'|'N'
---@field pattern? string
---@field nr? number
---@field valid? 0|1

do
  ---customs:
  ---* patten = '{fpath}|{lnum}|{text}'
  ---* {fpath} will be shortened or bufnr or empty
  ---* {col} no more
  ---* {text} will be left-trimmed
  ---@param pickle sting.Pickle
  ---@return string @pattern='<filename>|<lnum> col <col>|<text>'
  local function default_flavor(pickle)
    local text
    if pickle.text ~= nil then
      text = strlib.ltrim(pickle.text)
    else
      text = ""
    end

    local fpath
    if pickle.filename ~= nil then
      fpath = fs.shorten(pickle.filename)
    elseif pickle.bufnr ~= nil then
      fpath = string.format("buf#%d", pickle.bufnr)
    else
      fpath = ""
    end

    local lnum = fn.nilor(pickle.lnum, 0)

    return string.format("%s|%d|%s", fpath, lnum, text)
  end

  ---@class sting.Shelf
  ---@field private name string
  ---@field private flavor? fun(pickle: sting.Pickle): string
  ---@field private shelf sting.Pickle[]
  ---@field private thelf? string[]
  local Prototype = {}

  Prototype.__index = Prototype

  function Prototype:reset()
    self.shelf = {}
    self.thelf = nil
  end

  function Prototype:append(pickle)
    assert(self.thelf == nil, "after fed vim, this shelf is supposed to be frozen")
    table.insert(self.shelf, pickle)
  end

  ---@param list sting.Pickle[]
  function Prototype:extend(list)
    assert(self.thelf == nil, "after fed vim, this shelf is supposed to be frozen")
    listlib.extend(self.shelf, list)
  end

  function Prototype:feed_vim() error("not implemented") end

  ---@private
  ---@param info {quickfix: 0|1, winid: integer, id: integer, start_idx: integer, end_idx: integer}
  ---@return string[]
  function Prototype:quickfixtextfunc(info)
    assert(self.flavor ~= nil)
    assert(info.start_idx == 1 and info.end_idx == #self.shelf)
    if self.thelf == nil then
      local thelf = {}
      for _, pickle in ipairs(self.shelf) do
        table.insert(thelf, self.flavor(pickle))
      end
      assert(#thelf == #self.shelf)
      self.thelf = thelf
      self.shelf = {}
    end
    return self.thelf
  end

  ---@param name string
  ---@param flavor? true|(fun(pickle: sting.Pickle): string)
  ---@return sting.Shelf
  function M.Shelf(name, flavor)
    if flavor == true then flavor = default_flavor end
    return setmetatable({ name = name, list = {}, flavor = flavor }, Prototype)
  end
end

return M
