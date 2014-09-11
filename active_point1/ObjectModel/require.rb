require 'RubyExt/require'
require 'RubyExt/debug'
require 'sequel'
require 'StreamStorage/require'

require 'sync'

require 'ruby2ruby'
require 'parse_tree'
require 'parse_tree_extensions'

require 'facets/lrucache'

module ObjectModel
	# Config
	CONFIG = {
    :directory => ".",
    :buffer_size => 8192,
    :cache => "ObjectModel::Tools::NoCache",
    :cache_parameters => 0.2,
  }      
  
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

