# Code Coverage.
require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end
SimpleCov.at_exit do
  SimpleCov.result.format!
  Kernel.exec 'open ./coverage/index.html'
end