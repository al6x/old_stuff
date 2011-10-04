require 'MicroContainer/require'
require 'ObjectModel/require'
require 'OMExt/require'
require 'json'

# Handy Scope	
Scope = MicroContainer::Scope
Managed = MicroContainer::Managed	
Injectable = MicroContainer::Injectable

Entity = ObjectModel::Entity
Transaction = ObjectModel::Transaction
Locale = OMExt::Locale

Configurator = ActivePoint::Engine::Extensions::Configurator

# Others
%w{
Engine/initialize
Engine/OMExtension/initialize
Engine/OMExtension/entity
Engine/OMExtension/repository
}.each{|file| require "#{File.dirname __FILE__}/#{file}"}