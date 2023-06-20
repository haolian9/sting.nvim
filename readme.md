an opinionated way to use quickfix/location list

## status
* no stable api
* not usable

## usages

* to replace `setqflist()`
* to replace `vim.diagnostic.setloclist()`

## todo
* [ ] ~~using tv_{list,dict} & set_errorlist() to converting and copying data from lua to typval~~ due to inevitable gc
* [ ] embrace quickfix stack: allocate and maintain dedicated positions in the stack for each namespace
