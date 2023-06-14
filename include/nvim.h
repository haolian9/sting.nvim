typedef void *win_T;
typedef void *list_T;
typedef void *dict_T;

// Populate the quickfix list with the items supplied in the list
// of dictionaries. "title" will be copied to w:quickfix_title
// "action" is 'a' for add, 'r' for replace.  Otherwise create a new list.
// When "what" is not NULL then only set some properties.
int set_errorlist(win_T *wp, list_T *list, int action, char *title, dict_T *what);
