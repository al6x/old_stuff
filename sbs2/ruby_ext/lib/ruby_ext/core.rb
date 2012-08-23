raise 'ruby 1.9.2 or higher required!' if RUBY_VERSION < '1.9.2'

%w(
  basic_object
  nil_class
  enumerable
  array
  hash
  object
  module
  not_defined
  string
  symbol
  deep_clone
  time
  multiple_inheritance
).each{|f| require "ruby_ext/core/#{f}"}

autoload :OpenObject, 'ruby_ext/core/open_object'