require 'ActivePoint/require'
require 'spec_require'

describe "Core" do	
	it "Add & Delete Group" do		
		# Add
		go "Core/Users"		
		click "Groups"
		click "Add"
		should_have "Edit Group"
		attribute("Name:").type "Test Group"
		click "Ok"
		should_have "Users"
		should_have :link, "Test Group"
		
		# Add User
		click "Test Group"
		should_have "Test Group"
		click "Add"
		should_have "Add User"
		attribute_bottom_of("Add User").select "Anonymous"
		click "Ok"
		should_have "Test Group"
		should_have :link, "Anonymous"
		
		# Check that user has Included In attribute
		click "Anonymous"
		should_have ("User")
		should_have :link, "Test Group"
		
		# Add Group
		go "Core/Users/Test Group"
		click "Groups"
		click "Add"
		attribute_bottom_of("Add Group").select "AnonymousGroup"
		click "Ok"
		should_have "Test Group"
		should_have :link, "AnonymousGroup"
		
		# Delete Test Group
		go "Core/Users"
		click "Groups"
		attribute_left_of(:link, "Test Group").check
		click "Delete"
		should_not_have :link, "Test Group"
	end
	
	it "Add & Delete User" do
		# Add
		go "Core/Users"		
		click "Add"		
		should_have "Edit User" 		
		attribute("Name:").type "Test User"
		click "Ok"
		should_have :link, "Test User"
		
		# View
		click "Test User"
		attribute("Name:").text.should == "Test User" 
		
		# Delete
		go "Core/Users"
		attribute_left_of(:link, "Test User").check
		click "Delete"
		should_not_have "Test User"
	end
end