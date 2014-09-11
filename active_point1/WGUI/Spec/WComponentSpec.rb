require 'WGUI/web_spec'

module WGUI
	module WComponentSpec
		describe "ComponentWiget" do
			
			class CustomTemplate < WComponent
				children :@label
				def initialize
					super
					@label = Label.new "Label"
				end
			end
			
			register_wiget "Custom template" do
				CustomTemplate.new
			end
						
			register_wiget "Displays child twice (from error)" do
				v = View2.new
				v.root = Label.new "Child"
				v
			end													
			
			it "Custom template" do
				go 'localhost:8080/?t=Custom template'
				wait_for.should have_text('Label')
			end															
		end
	end
end