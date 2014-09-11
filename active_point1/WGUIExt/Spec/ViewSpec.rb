require 'WGUI/require'
require 'WGUIExt/require'
WGUI::Utils::TestServer

#require "#{File.dirname(__FILE__)}/extension"

module WGUIExt		  
	register_wiget "Should be rebuilded after Refresh" do
		class RebuildObject
			attr_accessor :counter
		end
		class RebuildView < WComponent
			inherit View
			
			build_view do |v|
				p :rebuilded
				v.root = v.add(:counter, :string_view)
			end
		end
		
		class RebuildContainer < WComponent
			def initialize
				super
				counter = RebuildObject.new
				counter.counter = 0
				@view = RebuildView.new
				@view.object = counter
				
				@btn = WButton.new "Update" do
					counter.counter += 1	
					@view.refresh
				end								
			end
		end
		
		RebuildContainer.new
	end
	
	start_webserver
	join_webserver
end	