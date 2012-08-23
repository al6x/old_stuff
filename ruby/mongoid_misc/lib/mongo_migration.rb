require 'mongo_ext'

class Mongo::Migration; end

%w(
  definition
  migration
).each{|f| require "mongo_migration/#{f}"}

Mongo.class_eval do
  class << self
    attr_accessor :migration
  end
end