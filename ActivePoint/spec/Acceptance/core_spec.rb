require 'ActivePoint/require'
require 'spec_require'

describe "Core" do	
	it "General Check" do		
		go "Core"
		should_have "Plugins"
		should_have :link, "Properties"
		
		click "Properties"
		should_have "Layout:"
		
		should_have "Skin"
		should_have "Skin:"
		
		should_have "Security"
		should_have "Police:"
		should_have "Object Owner:"
		
		count(:button, "Set").should == 3
	end
end