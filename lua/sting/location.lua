local M = {}

local dictlib = require("infra.dictlib")
local jelly = require("infra.jellyfish")("sting.location", "debug")

local types = require("sting.types")
local tui = require("tui")

local api = vim.api

---@param room sting.location.Room
---@param name string
local function Shelf(room, name)
  local shelf = types.Shelf(name, true)
  shelf.room = room

  function shelf:feed_vim()
    ---@diagnostic disable: invisible
    if self.room.last_fed_name == self.name then return end
    do
      vim.fn.setloclist(self.room.winid, {}, "f")
      if self.flavor == nil then
        vim.fn.setloclist(self.room.winid, self.shelf, " ")
      else
        vim.fn.setloclist(self.room.winid, {}, " ", { items = self.shelf, quickfixtextfunc = function(...) return self:quickfixtextfunc(...) end })
      end
    end
    self.room.last_fed_name = self.name
  end
  return shelf
end

local Room
do
  ---@class sting.location.Room
  ---@field private winid number
  ---@field private last_fed_name string?
  ---@field private shelves {[string]: sting.Shelf}
  local Prototype = {}
  Prototype.__index = Prototype

  ---@param name string
  function Prototype:shelf(name)
    if self.shelves[name] == nil then self.shelves[name] = Shelf(self, name) end
    return self.shelves[name]
  end

  function Prototype:switch()
    tui.menu(dictlib.keys(self.shelves), { prompt = string.format("switch location shelves in win#%d", self.winid) }, function(name)
      if name == nil then return end
      if name == self.last_fed_name then return end
      assert(self.shelves[name]):feed_vim()
    end)
  end

  function Room(winid) return setmetatable({ winid = winid, shelves = {} }, Prototype) end
end

---@type {[integer]: sting.location.Room}
local rooms = {}

do
  local aug = api.nvim_create_augroup("sting.location", { clear = true })
  api.nvim_create_autocmd("winclosed", {
    group = aug,
    callback = function(args)
      local winid = tonumber(args.match)
      assert(winid ~= nil and winid >= 1000)
      rooms[winid] = nil
    end,
  })
end

function M.shelf(winid, name)
  assert(winid ~= nil and winid ~= 0)
  if rooms[winid] == nil then rooms[winid] = Room(winid) end
  return rooms[winid]:shelf(name)
end

function M.switch(winid)
  winid = winid or api.nvim_get_current_win()
  assert(winid ~= 0)
  if rooms[winid] == nil then return jelly.info("no shelves under win#%d", winid) end
  rooms[winid]:switch()
end

function M.clear() rooms = {} end

return M
