require 'mongo_mapper'


[
  'hacks/fixes',
  'hacks/time_measuring',
  'migration',
  'mongo_mapper',
  'view_helpers',
  'db_config',
  'micelaneous',
  
  'plugins/default_scope',
  'plugins/attributes_cache',
  'plugins/micelaneous',  
].each do |file|
  require "#{File.dirname __FILE__}/mongo_mapper_ext/#{file}"
end

module CommonPluginsAddition
  def self.included(model)
    model.plugin MongoMapper::Plugins::DefaultScope
    model.plugin MongoMapper::Plugins::AttributesCache
    model.plugin MongoMapper::Plugins::Micelaneous
    
    model.attr_protected :id, :_id, :_type, :created_at, :updated_at
  end
end
MongoMapper::Document.append_inclusions(CommonPluginsAddition)