require 'MicroContainer/require'

require 'ObjectModel/require'

require 'WGUI/require'
require 'WGUIExt/require'

# Handy Scope	
Scope = MicroContainer::Scope
Managed = MicroContainer::Managed	
Injectable = MicroContainer::Injectable

Entity = ObjectModel::Entity
Transaction = ObjectModel::Transaction

# Others
%w{
Engine/initialize
Engine/ObjectModel/initialize
Engine/ObjectModel/entity
WebClient/initialize
}.each{|file| require "#{File.dirname __FILE__}/#{file}"}

# Handy Scope	
Controller = ActivePoint::WebClient::Controller
ActivePoint::UserError = ActivePoint::Engine::UserError