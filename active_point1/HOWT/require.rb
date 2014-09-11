require 'RubyExt/require'
require 'ostruct'
require 'cgi'

module HOWT
  begin   
    CONFIG = HOWT["config.yaml"]
  rescue Exception => e
    raise "No HOWT config file (#{e.message})!"
  end
  
  begin
    require "#{CONFIG[:path_to_selenium_rb]}"
  rescue Exception
    raise "Invalid path to the 'selenium.rb' file!"
  end
end