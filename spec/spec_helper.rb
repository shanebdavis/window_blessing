require 'simplecov'
SimpleCov.start do
  add_filter "vendor/ruby"
end

require File.join(File.dirname(__FILE__),"..","lib","window_blessing")
