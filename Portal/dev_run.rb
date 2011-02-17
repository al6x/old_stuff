require 'ActivePoint/require'
require 'Portal/require'

WGUIExt::Editors::RichTextData # hack

#require "facets/daemonize"
#WGUI::CONFIG[:uidriver_mode] = true

#Kernel.daemonize

#config = {
#	:directory => "/home/alex/Temp/data",
#	:initialize => lambda{},
#	:default_object => 'Portal',
##	:reloading => false,
#	:initialize_core => lambda{
#		portal = Portal::Core::Model::Portal.new "Portal", "Portal"
#		portal.core = ActivePoint::Plugins::Core::Model::Core.new "Core", "Core"		
#	},
#	:plugins => [
#	Portal::Core,
#	Portal::Blog,
#	Portal::Site,
#	],
#	:services => [
#	Portal::Services::ContactUs
#	],
#	:disable_security => true,
##	:cache => "ObjectModel::Tools::InMemoryCache",
#	:default_language => :en,
##	:reset_data => true
#}

ActivePoint::Engine.activate #config

#WGUIExt::Editors::RichTextData
#ActivePoint::Engine.reset_data!
#Portal::Site::Samples::SampleData.install

ActivePoint::Engine.join
