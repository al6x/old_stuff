require 'ActivePoint/require'
require 'spec_require'

describe "Core" do	
		it "Should be Secure" do
			enable_security
			go "Core"
			should_have /You hasn/
		end
		
		it "Login & Logout" do
			enable_security
			go ""
			should_have "Anonymous"
			should_not_have "admin"
			
			# Login
			click "Login"
			should_have "Login"
			attribute("Name:").type "admin"
			click "Ok"
			should_have "admin"
			
			# Logout
			should_have :link, "Logout"
			click "Logout"
			should_have "Anonymous"
		end
		
		it "General Check" do		
			disable_security
			go "Core/Security"
			should_have "Security"
			should_have "Policies"
			should_have "Default Policy:"
			
			should_have :button, "Set"
			should_have :button, "Add"
			
			should_have :link, "Roles"		
			should_have :link, "Permissions"
		end
		
		it "Add Test Role" do
			disable_security
			go "Core/Security"
			# Add Role
			click "Roles"
			should_have "Roles"
			click "Add"
			should_have "Edit Role"
			attribute("Name:").type "Test Role"
			click "Ok"
			should_have "Security"
			
			# Edit Permissions
			click "Test Role"
			should_have "Test Role"
			click "Edit Permissions"
			should_have "Edit Permissions"
			attribute_near("Edit Permissions").select "view"
			click "Ok"
			should_have "Test Role"
			should_have "view"
			
			# Delete Role
			go "Core/Security"		
			click "Roles"
			attribute_left_of(:link, "Test Role").check
			click "Delete"
			should_not_have :link, "Test Role"
		end
		
		it "Add Test Policy" do
			disable_security
			go "Core/Security"
			# Add
			click "Add"
			should_have "Edit Policy"
			attribute("Name:").type "Test Policy"
			click "Ok"
			should_have "Security"
			should_have :link, "Test Policy"
			
			# Delete
			attribute_left_of(:link, "Test Policy").check
			click "Delete"
			should_not_have :link, "Test Policy"
		end
		
		it "Security Policy CRUD" do	
			disable_security
			go "Core/Security"
			
			# Add
			click "Add"
			should_have "Edit Policy"
			attribute("Name:").type "Test Policy"
			click "Ok"
			should_have :link, "Test Policy"
			
			# Edit
			click "Test Policy"
			should_have "Test Policy"
			click "Edit"
			should_have "Edit Security Map"
			# Add Groups
			click "Edit Groups"
			should_have "Edit Groups"
			attribute_bottom_of("Edit Groups").select "AnonymousGroup", "Developers"
			click "Ok"
			should_have "Edit Security Map"
			
			# Add Roles
			click "Edit Roles"
			should_have "Edit Roles"
			attribute_bottom_of("Edit Roles").select "Viewer", "Editor", "Manager"
			click "Ok"
			should_have "Edit Security Map"
			
			# Edit Security Map
			cell("AnonymousGroup", "Editor").selection.should == []
			cell("AnonymousGroup", "Editor").select "yes"
			click "Ok"
			should_have "Test Policy"
			cell("AnonymousGroup", "Editor").text.should == "yes"
			
			# Delete
			go "Core/Security"
			attribute_left_of(:link, "Test Policy").check
			click "Delete"
			should_not_have :link, "Test Policy"
		end
	
	it "Check Impact of Security Police Changes" do
		enable_security
		go "Core/Security"
		should_have /You hasn/
		should_not_have "Security"
		
		# Add Policy for Anonymous to view Security
		script = <<END_
security = R.by_id("Security")
R.transaction(Transaction.new){
	tp = ActivePoint::Plugins::Security::Model::Policy.new "Test Policy"
	anon_group = ActivePoint::Plugins::Users::Model::Group::ANONYMOUS
	tp.map = {
		security["Viewer"].entity_id => {anon_group => true},
	}
	security.policies << tp
	
	R.by_id("Core").set_policy tp
}.commit
END_

		rest_client["Core/Development"].eval script
		go "Core"
		go "Core/Security"
		should_not_have /You hasn/
		should_have "Security"
	end
end