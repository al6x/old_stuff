require 'WGUI/require'

module WGUI
	module PortletSpec
		class RootPortlet < WComponent
			extend Managed
			include WPortlet
			
			scope :session
			
			def state= state
				@state = state
			end
			
			def state
				@state
			end
			
			def initialize
				super
				self.component_id = "root"
				@label = Label.new "I'm Root Portlet"
			end
		end
		
		Runner.start RootPortlet, "root"
		Runner.join
			
#			it "Root Portlet" do
#				go 'localhost:8080/?'
#				wait_for{uri =~ /localhost:8080\/\?/}
#				go 'localhost:8080/path1/path2?'
#				wait_for{uri =~ /localhost:8080\/path1\/path2\?/}
#			end
	end
end