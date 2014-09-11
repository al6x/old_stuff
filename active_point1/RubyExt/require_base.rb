require 'monitor'
require 'singleton'
require 'set'

class NotDefined; end

# Core Classes, can't be excluded.
%w{
kernel module object class file
}.each{|n| require "RubyExt/#{n}"}

require 'RubyExt/assert'
require 'RubyExt/observable'

require 'RubyExt/resource'
require 'RubyExt/Resource/file_system_provider'

# Need this complex loading for correct work of 'raise_without_self''
module RubyExt
	Resource.add_resource_provider FileSystemProvider.new
		
  script = Resource.class_get "RubyExt::ClassLoader"
  eval script, TOPLEVEL_BINDING, Resource.class_to_virtual_file("RubyExt::ClassLoader")  
end