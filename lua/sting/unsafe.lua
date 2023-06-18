local M = {}

local ffi = require("ffi")

ffi.cdef([[
  typedef void *win_T;
  typedef void *list_T;
  typedef void *dict_T;
  typedef void *typval_T;

  // Populate the quickfix list with the items supplied in the list
  // of dictionaries. "title" will be copied to w:quickfix_title
  // "action" is 'a' for add, 'r' for replace.  Otherwise create a new list.
  // When "what" is not NULL then only set some properties.
  int set_errorlist(win_T *wp, list_T *list, int action, const char *title,
                    dict_T *what);

  list_T *tv_list_alloc(const long len);
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

function M.clear_qf_stack() C.set_errorlist(NULL, NULL, "f", NULL, NULL) end

---@param list any @list_T *
---@param title? string
function M.set_qf_list(list, title) C.set_errorlist(NULL, list, " ", title, NULL) end

---@param list any @list_T *
function M.free_list(list) C.tv_list_free(list) end

return M
