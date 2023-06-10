local jelly = require("infra.jellyfish")("sting.location", vim.log.levels.DEBUG)
local tui = require("tui")
local types = require("sting.types")

local api = vim.api

---@class sting.LocMod
---@field private winid number
---@field items sting.Items
local LocMod = {}
do
  LocMod.__index = LocMod

  --caution: the quickfix stack will be cleared after this function
  ---@param ns string
  ---@return true?
  function LocMod:feed_vim(ns)
    local items = self.items:get(ns)
    if items == nil then return jelly.warn("no qf items under namespace '%s'", ns) end
    vim.fn.setloclist(self.winid, {}, "f") -- intended to clear the whole quickfix stack
    vim.fn.setloclist(self.winid, {}, " ", { items = items })
  end

  function LocMod:switch()
    tui.menu(self.items:namespaces(), { prompt = "switch location namespace" }, function(ns)
      if ns == nil then return end
      self:feed_vim(ns)
    end)
  end
end

local mods = {}

do
  local aug = api.nvim_create_augroup("sting.location", { clear = true })
  api.nvim_create_autocmd("winclosed", {
    group = aug,
    callback = function(args)
      local winid = tonumber(args.match)
      assert(winid ~= nil and winid >= 1000)
      mods[winid] = nil
    end,
  })
end

---@param winid number
---@return sting.LocMod
return function(winid)
  assert(api.nvim_win_is_valid(winid))
  if mods[winid] == nil then mods[winid] = setmetatable({ winid = winid, items = types.Items({}) }, LocMod) end
  return mods[winid]
end
