require 'RubyExt/require'

require 'sequel'

require 'sync'

require 'ruby2ruby'
require 'parse_tree'
require 'parse_tree_extensions'

require 'facets/lrucache'

module ObjectModel
	# Config	
	user_conf = if File.exist?("config/object_model.yaml") 
		YAML.load(File.read("config/object_model.yaml"))
	else
		{}
	end
	CONFIG = RubyExt::Config.new({}, user_conf, ObjectModel["config.yaml"])
	
	# Metadata
	require "#{File.dirname(__FILE__)}/Metadata/require"
	
	# ObjectStorage Initialization
	[
	AnEntity::BackReferences,
	AnEntity::EntityType,
	Types::BagType,
	Types::ObjectType,
	].each{|type| Repository::ObjectStorage::TYPES_TO_INITIALIZE << type}
	
	# Handy Scope  
	NotFoundError = Errors::NotFoundError
	OutdatedError = Errors::OutdatedError
	NoTransactionError = Errors::NoTransactionError
	LoadError = Errors::LoadError
	ValidationError = Errors::ValidationError
	StreamID = Repository::StreamID
	Transaction = Repository::Transaction
	HashIndex = Indexes::HashIndex
end

