an opinionated way to use quickfix/location list

## usages

to replace `setqflist()`

```
---@type fun(line: string): sting.Item
local rg_to_qf

quickfix.items:set(ns, {})
for line in output_iter do
  quickfix.items:append(ns, rg_to_qf(line))
end
quickfix:feed_vim(ns)
```


to replace `vim.diagnostic.setloclist()`

```
local api = vim.api
local diag = vim.diagnostic

---@param opts {namespace: number, winnr: number, open: boolean, title: string, severity: number}
function diag.setloclist(opts)
  opts = opts or {}

  local winid
  do -- no more winnr
    if opts.winnr == nil then
      winid = api.nvim_get_current_win()
    else
      winid = vim.fn.win_getid(opts.winnr)
    end
    opts.winnr = winid
  end

  local items
  do
    local bufnr = api.nvim_win_get_buf(winid)
    local diags = diag.get(bufnr, opts)
    items = diag.toqflist(diags)
  end

  do
    local location = require("sting.location")(winid)
    local ns = "vim.diagnostic"
    location.items:set(ns, items)
    location:feed_vim(ns)
    vim.cmd('lwindow')
  end
end
```
