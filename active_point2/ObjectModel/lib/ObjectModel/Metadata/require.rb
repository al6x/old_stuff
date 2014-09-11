ObjectModel::Metadata
ObjectModel::Metadata::DSL
%w{
attribute 
child
events
name
reference
validate
}.each{|file| require "#{File.dirname(__FILE__)}/#{file}"}