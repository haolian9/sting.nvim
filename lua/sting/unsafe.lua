local M = {}

local ffi = require("ffi")

ffi.cdef([[
  typedef void *win_T;
  typedef void *list_T;
  typedef void *dict_T;
  typedef void *typval_T;

  // Find window "handle" in the current tab page.
  // Return NULL if not found.
  win_T *win_find_by_handle(int nr);

  // Populate the quickfix list with the items supplied in the list
  // of dictionaries. "title" will be copied to w:quickfix_title
  // "action" is 'a' for add, 'r' for replace.  Otherwise create a new list.
  // When "what" is not NULL then only set some properties.
  int set_errorlist(win_T *wp, list_T *list, int action, const char *title,
                    dict_T *what);

  list_T *tv_list_alloc(const long len);
  void tv_list_init_static(list_T *list);
  void tv_list_append_dict(list_T *const list, dict_T *const dict);
  void tv_list_free(list_T *const list);

  dict_T *tv_dict_alloc(void);
  int tv_dict_add_str(dict_T *const dict, const char *const key,
                      const size_t key_len, const char *const val);
  int tv_dict_add_nr(dict_T *const dict, const char *const key,
                    const size_t key_len, const int64_t nr);
]])

local C = ffi.C
local NULL = nil

---list_T *
---@class clist

---dict_T *
---@class cdict

do
  local quickfix = {}
  function quickfix.clear_stack() C.set_errorlist(NULL, NULL, string.byte("f"), NULL, NULL) end
  ---@param list clist @list_T *
  ---@param title? string
  function quickfix.new(list, title) C.set_errorlist(NULL, list, string.byte(" "), title, NULL) end
  ---@param list clist @list_T *
  ---@param title? string
  function quickfix.extend(list, title) C.set_errorlist(NULL, list, string.byte("a"), title, NULL) end
  M.quickfix = quickfix
end

do
  local dicts = {}
  ---@return cdict
  function dicts.alloc() return C.tv_dict_alloc() end
  ---@param dict cdict
  ---@param k string
  ---@param v string|number
  function dicts.add(dict, k, v)
    local vtype = type(v)
    if vtype == "string" then
      C.tv_dict_add_str(dict, k, #k, v)
    elseif vtype == "number" then
      C.tv_dict_add_nr(dict, k, #k, v)
    else
      error("unreachable: unexpected value type: " .. vtype)
    end
  end
  M.dicts = dicts
end

do
  local lists = {}
  ---@param list clist @list_T *
  function lists.free(list) C.tv_list_free(list) end
  ---@param len number
  ---@return clist @list_T *
  function lists.alloc(len)
    local list = C.tv_list_alloc(len)
    C.tv_list_init_static(list) -- to avoid it being gc
    return list
  end
  ---@param list clist
  ---@param dict cdict
  function lists.append_dict(list, dict) C.tv_list_append_dict(list, dict) end
  M.lists = lists
end

return M
