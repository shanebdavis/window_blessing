module Foiled
class XtermLog
  def self.log(str)
    File.open("xterm.log","a+") {|f| f.puts str}
  end
end
end
