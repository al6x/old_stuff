require 'ActivePoint/require'
require 'spec_require'

describe "Appearance" do	
	
	it "General Check" do				
		go "Core/Appearance"
		should_have "Appearance"
		should_have "Wigets"
		should_have :link, "Layouts"
		
		should_have "ObjectView"
		should_have "Messages"
		should_have "User Menu"
		
		should_have :button, "Add"
		should_have :button, "Delete" 
		
		click "Layouts"
		should_have :button, "Add"
	end
	
	it "Add & Delete Wigets" do				
		# Adding
		go "Core/Appearance"
		click "Add"
		should_have "Edit Wiget"
		attribute("Name:").type "TestWiget"
		attribute("Wiget Class:").type "::ActivePoint::Adapters::Web::Wigets::Messages"
		click "Ok"			
		should_have "Appearance"
		should_have :link, "TestWiget" 
		
		# Viewing		
		click "TestWiget"		
		should_have "Wiget"
		should_have :button, "Edit"		
		
		# Deleting
		go "Core/Appearance"		
		attribute_left_of(:link, "TestWiget").check
		click "Delete"
		should_not_have :link, "TestWiget"
	end

	it "Add & Delete Layout" do
		go "Core/Appearance"
		click "Layouts"
		
		# Add
		should_have "Layouts"
		click "Add"
		should_have "Select Layout Class"
		attribute_bottom_of("Select Layout Class").select "Border Layout"
		click "Ok"
		should_have "Edit Layout"
		attribute("Name:").type "Test Layout"
		click "Ok"
		should_have "Appearance"
		should_have :link, "Test Layout"
		
		# View Layout
		click "Test Layout"
		should_have "Test Layout"
		go "Core/Appearance"
		
		# Delete Layout
		click "Layouts"
		should_have "Layouts"
		attribute_left_of(:link, "Test Layout").check
		click "Delete"
		should_not_have :link, "Test Layout"
	end
	
	it "Skinnable" do
		go "Core"
		should_have "Core"
		click "Properties"
		should_have "Properties"				
		control("Set", :right_of, "Skin:").click
		should_have "Set Skin"
	end
	
	it "Layout" do
		go ""
		should_have "Core"
		click "Properties"
		should_have "Properties"
		control("Set", :right_of, "Layout:").click		
		should_have "Select Layout"
	end
end