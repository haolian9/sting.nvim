local M = {}

local jelly = require("infra.jellyfish")("sting.quickfix", vim.log.levels.DEBUG)
local tui = require("tui")
local types = require("sting.types")

M.items = types.Items({})

--caution: the quickfix stack will be cleared after this function
---@param ns string
---@return true?
function M:feed_vim(ns)
  local items = self.items:get(ns)
  if items == nil then return jelly.warn("no qf items under namespace '%s'", ns) end
  vim.fn.setqflist({}, "f") -- intended to clear the whole quickfix stack
  vim.fn.setqflist({}, " ", { items = items })
end

function M:switch()
  tui.menu(self.items:namespaces(), { prompt = "switch quickfix namespace" }, function(entry)
    if entry == nil then return end
    self:feed_vim(entry)
  end)
end

return M
