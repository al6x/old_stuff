require "UIDriver/Client/require"
require "spec"

module UIDRiver				
	describe "Usability" do				
		include RSpecBrowserExtension
		
		before :each do 
			self.browser = Browser.new("localhost:7000") 
			@b2 = Browser.new("localhost:7000") 
		end
		
		after :each do 
			browser.close 
			@b2.close
		end				
		
		it "should have, should_not have" do
			go "usability/text"
			browser.has?(:text, "Text").should be_true
			should have("Text")
			should_not have("invalid Text")								
			
			@b2.go "usability/text"
			@b2.should have("Text")
			@b2.should_not have("invalid Text")			
		end
		
		it "should_have (from error)" do
			go "usability/text"
			should_have "Text"
			should_have :button, "Button"
			should_have :text, "Text"
		end
		
		it "should_have, should_not_have" do
			go "usability/text"
			should_have "Text"
			should_not_have "invalid Text"
			
			lambda{should_not_have "Text"}.should raise_error(/expected.+has_text.+/)
			lambda{should_have "invalid Text"}.should raise_error(/expected.+has_text.+/)
			
			@b2.go "usability/text"
			@b2.should_have "Text"
			@b2.should_not_have "invalid Text"
			
			lambda{@b2.should_not_have "Text"}.should raise_error(/expected.+has_text.+/)
			lambda{@b2.should_have "invalid Text"}.should raise_error(/expected.+has_text.+/)
		end
		
		it "attribute" do
			go "usability/page"
			attribute("Attribute1:").text.should == "AttributeValue1"
			lambda{attribute("Attribute1:").text.should == "invalid_value"}.should raise_error(/invalid_value/)
		end
		
		it "area, area_by_id, area_by_class, nested areas" do					
			go "usability/page"
			should_have "MMLink1"
			
			done = false			
			area single("//*[@id='object']") do
				should_not_have "MMLink1"	
				should_not_have "LMLink1"
				should_have "Attribute3:"
				
				area_by_id :left_side do
					should_not_have "Attribute3:"
					should_have "Attribute1:"
					
					done = true
				end								
			end		
			
			area_by_class :table_toolbar do
				should_not_have "MMLink1"
				should_have "TableButton1"
			end
			
			done.should be_true			
		end
		
		it "table, cell" do
			go "usability/page"
			area_by_id :table do
				cell("b", "2").text.should == "b2"
			end
		end
		
		it "area_by_template" do									
			register_template :page, 'usability/register_template', ["Object", "Main Menu", "Left Menu"]
			go "usability/page"
			area_by_template :page, "Object" do
				should_not_have "MMLink1"	
				should_have "Attribute3:"
			end			
		end
		
		it "text_selector" do
			# This case won't works without "text_selector". Because when we searching for all possible
			# attribute values for this attribute we cant search for any html tag, so we must explicitly 
			# specify wich tags can contains text.
			go "usability/text_selector"
			attribute("Attribute1:").text.should == "Text1"
		end
	end		
end		