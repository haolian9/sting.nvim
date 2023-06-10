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
--
-- todo:
-- * hijack setqflist outside sting.quickfix
-- * utilize :cfile to have caches
-- * performance
--   * embrace the quickfix stack for lesser data copying
--   * avoid calling fn.setqflist

-- to avoid fn.setqflist
-- * nvim symbols: set_errorlist
