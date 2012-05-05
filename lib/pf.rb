require "pf/version"
require "pf/file.rb"

module Pf
 def Pf.hello
  pwfile = Pf.File.new "testfile"
 end
end
