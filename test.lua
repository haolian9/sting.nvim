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

do -- main
  local null_ptr = nil
  print("free stack", C.set_errorlist(null_ptr, null_ptr, string.byte("f"), null_ptr, null_ptr))
  local list_ptr = C.tv_list_alloc(1)
  local ok, err = pcall(function()
    print(vim.inspect(list_ptr))
    local dict_ptr = C.tv_dict_alloc()
    for k, v in pairs({ filename = "include/nvim.h", lnum = 21, col = 5, text = "world" }) do
      local vtype = type(v)
      if vtype == "string" then
        C.tv_dict_add_str(dict_ptr, k, #k, v)
      elseif vtype == "number" then
        C.tv_dict_add_nr(dict_ptr, k, #k, v)
      else
        error("unreachable")
      end
    end
    C.tv_list_append_dict(list_ptr, dict_ptr)
  end)
  C.set_errorlist(null_ptr, list_ptr, string.byte("a"), "test", null_ptr)
  -- C.tv_list_free(list_ptr)
  if not ok then error(err) end
end
