require 'RubyExt/require_base'

# Ruby Classes extensions
%w{
symbol string array false_class true_class nil_class
}.each{|n| require "RubyExt/#{n}"}

Path = RubyExt::Path
Log = RubyExt::Log
Observable = RubyExt::Observable
OpenConstructor = RubyExt::OpenConstructor
Cache = RubyExt::Cache

# Facets
require 'facets/elementor'
require 'facets/blankslate'
# Dictionary, Crypt, BiCrypt, Duration, LRUCache, LinkedList, Timer, Memoizer,
# Recorder, attr_validator
# "TreeTop" - cool Ruby Parser DSL.

# ResourceProcessing
require 'yaml'
module RubyExt
	Resource.register_resource_extension(
	".yaml",
	lambda{|data, klass, name| YAML.load(data)}, 
	lambda{|data, klass, name| YAML.dump(data)}
	)
	
	Resource.register_resource_extension(
	".rb",
	lambda{|data, klass, name|
		script = ClassLoader.wrap_inside_namespace(klass, data)
		eval script, TOPLEVEL_BINDING, "#{klass.name}/#{name}"
	}, 
	lambda{|data, klass, name| raise "Writing '.rb' Resource isn't supported!"}
	)	
end

# Cache
Cache.cached_with_params :class, Module, :resource_exist?, :[]

# Others
require 'fileutils'
# Undef
#[
#:select, :autoload, :autoload?, :chomp, :chomp!, :chop, :chop!, :fail, :format, :gsub,
#:gsub!, :iterator?, :open, :print, :printf, :puts, :putc, :readline, :readlines, :scan,
#:split, :sub, :sub!, :test, :trap, :warn
#].each do |m|
#	Kernel.send :undef_method, m
#end

# select