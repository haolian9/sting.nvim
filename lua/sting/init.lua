-- available apis:
-- * switch current list: :colder, :cnewer
-- * :copen
-- * quickfix stack: :chistory
-- * QuickfixCmdPost, QuickfixCmdPre
-- * :cfile
--
-- design choices
-- * no stack: setqflist({}, 'f')
-- * namespace
-- * textfunc
--
-- todo:
-- * textfunc
-- * utilize :cfile to have caches
-- * ~~hijack setqflist outside sting.quickfix~~ every part of my nvim rice use quickfix/location list should use this instead
-- * performance
--   * ~~embrace the quickfix stack for lesser data copying~~ no way to remove a member from the stack
--   * ~~avoid calling fn.setqflist~~ impossible

return {
  quickfix = require("sting.quickfix"),
  location = require("sting.location"),
}
