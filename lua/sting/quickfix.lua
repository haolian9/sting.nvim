local M = {}

local jelly = require("infra.jellyfish")("sting.quickfix", vim.log.levels.DEBUG)

local types = require("sting.types")
local tui = require("tui")

M.items = types.Items({})

---@private
M.last_fed_ns = nil

--caution: the quickfix stack will be cleared after this function
---@param ns string
---@return true?
function M.feed_vim(ns)
  local items = M.items:get(ns)
  if items == nil then return jelly.warn("no qf items under namespace '%s'", ns) end
  vim.fn.setqflist({}, "f") -- intended to clear the whole quickfix stack
  vim.fn.setqflist(items, " ")
  M.last_fed_ns = ns
end

function M.switch()
  tui.menu(M.items:namespaces(), { prompt = "switch quickfix namespace" }, function(ns)
    if ns == nil then return end
    if ns == M.last_fed_ns then return end
    M.feed_vim(ns)
  end)
end

return M
