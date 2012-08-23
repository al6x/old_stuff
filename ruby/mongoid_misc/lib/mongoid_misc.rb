require 'mongoid_misc/gems'

require 'mongo_ext'
require 'mongoid'
require 'will_paginate'

%w(
  hacks
  support
  
  attribute_cache
  attribute_convertors
  belongs_to_with_counter_cache
  simple_finders
  miscellaneous
).each{|file| require "mongoid_misc/#{file}"}

# 
# Default plugins
# 
[
  Mongoid::AttributeCache,
  Mongoid::AttributeConvertors, 
  Mongoid::BelongsToWithCounterCache, 
  Mongoid::SimpleFinders, 
  Mongoid::Miscellaneous
].each{|plugin| Mongoid::Document.send :include, plugin}
  

# 
# Locales
# 
# Mongoid.add_language "*" - can't use this there's some bug, haven't time to investigate it
Mongoid.add_language "en"
Mongoid.add_language "ru"

dir = File.expand_path "#{__FILE__}/../.."
I18n.load_path += Dir["#{dir}/config/locales/**/*.{rb,yml}"]