local M = {}

local ex = require("infra.ex")
local fn = require("infra.fn")
local prefer = require("infra.prefer")
local strlib = require("infra.strlib")

local api = vim.api

local default_height = 10

--NB: use `cwin height` instead of ex(cwin, height), due to https://github.com/neovim/neovim/issues/21313

---@param height integer
---@return boolean
local function cwin(height)
  ex(string.format("%s %d", "cwin", height))
  return prefer.bo(api.nvim_get_current_buf(), "buftype") == "quickfix"
end

---@param height integer
---@return boolean
local function lwin(height)
  local ok, err = pcall(ex, string.format("%s %d", "lwin", height))
  if ok then return true end
  assert(strlib.find(err, "E776"))
  return false
end

---@param tabid integer
---@return fun(): {quickfix: 0|1, loclist: 0|1}?
local function iter_wininfo(tabid)
  tabid = tabid or api.nvim_get_current_tabpage()
  return fn.map(function(winid) return vim.fn.getwininfo(winid)[1] end, vim.api.nvim_tabpage_list_wins(tabid))
end

---@param tabid integer
---@return boolean,boolean @qfwin opened, locwin opened
local function has_opened_cl(tabid)
  local co, lo = false, false

  for info in iter_wininfo(tabid) do
    if info.quickfix == 1 then co = true end
    if info.loclist == 1 then lo = true end
  end

  -- it's possible that `lo == co == true` (see :help getwininfo)

  if lo then return false, true end
  if co then return true, false end
  return false, false
end

do
  ---@param tabid? integer
  ---@param height? integer
  ---@param keep_open boolean
  local function main(tabid, height, keep_open)
    tabid = tabid or api.nvim_get_current_tabpage()
    height = height or default_height

    local co, lo = has_opened_cl(tabid)

    --toggle off
    if co then
      if keep_open then return end
      return ex("cclose")
    end

    --toggle on
    if lo then ex("lclose") end
    cwin(height)
  end

  ---@param tabid? integer
  ---@param height? integer
  function M.qfwin(tabid, height) main(tabid, height, false) end

  ---@param tabid? integer
  ---@param height? integer
  function M.open_qfwin(tabid, height) main(tabid, height, true) end
end

do
  ---@param tabid? integer
  ---@param height? integer
  ---@param keep_open boolean
  local function main(tabid, height, keep_open)
    tabid = tabid or api.nvim_get_current_tabpage()
    height = height or default_height

    local co, lo = has_opened_cl(tabid)

    --toggle off
    if lo then
      if keep_open then return end
      return ex("lclose")
    end

    --toggle on
    if co then ex("cclose") end
    lwin(height)
  end

  ---@param tabid? integer
  ---@param height? integer
  function M.locwin(tabid, height) main(tabid, height, false) end

  ---@param tabid? integer
  ---@param height? integer
  function M.open_locwin(tabid, height) main(tabid, height, true) end
end

return M
