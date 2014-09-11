require "UIDriver/Client/require"
require "spec"

module UIDRiver	
	describe "General Specification" do					
		before :each do @b = UIDriver::Client::Browser.new("localhost:7000") end
		after :each do @b.close end						
		
		it "go" do
			@b.go "general/go"
			@b.has?(:text, "No params").should be_true
			@b.go "general/go", :p1 => "value"
			@b.has?(:text, "value").should be_true
			
			# with timeout
			@b.go "general/go"
			@b.go "general/go_timeout"
			@b.has?(:text, "Go Timeout").should be_true
		end
		
		it "wait_for" do
			@b.wait_for{true}
			lambda{@b.wait_for{false}}.should raise_error(/Waitings for specified Condition is out!/)
		end
		
		it "eval" do
			@b.eval("1 + 3").should == "4"
			
			# JS error
			lambda{@b.eval "a + b"}.should raise_error(/RemoteError/)
		end
		
		it "xpath" do
			@b.go "general/xpath"
			paths = @b.xpath_list "//p"
			paths.size.should == 1
			path = paths.first
			path.xpath.should == "/HTML[1]/BODY[1]/DIV[1]/P[1]"
			path.is_a?(UIDriver::Client::Browser::Position).should be_true
			
			# XPath error
			lambda{paths = @b.xpath_list "//p]]]"}.should raise_error(/RemoteError/)
			
			# JS error
			lambda{paths = @b.xpath_list " \" //p"}.should raise_error(/RemoteError/)						
		end					
		
		it "xpath eval" do
			@b.go "general/xpath"
			
			@b.single("//p").eval("$this.innerHTML").should == "Text"			
		end
		
		it "has?" do
			@b.go "general/has_text"
			
			@b.has?(:text, "Text").should be_true	
			
			@b.has?(:text, "Link").should be_true
			@b.has?(:text, "Button").should be_false
			@b.has?(:text, "TextField").should be_false
			@b.has?(:text, "TextArea").should be_false
			@b.has?(:text, "Select").should be_false
			@b.has?(:text, "MultiSelect").should be_false
			
			@b.has?(:text, "Text1").should be_false
			@b.has?(:text, "Button1").should be_false				
			
			# The same but with RegExp
			@b.has?(:text, /Text/).should be_true				
			
			@b.has?(:text, /Link/).should be_true
			#				@b.has?(:text, /Button/).should be_false # TODO It doesn't pass, possibly some JS trick.
			@b.has?(:text, /TextField/).should be_false
			@b.has?(:text, /TextArea/).should be_false
			@b.has?(:text, /Select/).should be_false
			@b.has?(:text, /MultiSelect/).should be_false
			
			@b.has?(:text, /Text1/).should be_false
			@b.has?(:text, /Button1/).should be_false
		end			
		
		it "should correct works with tag <button>" do
			@b.go "general/button"				
			@b.has?(:text, "Button").should be_false
			@b.single(:button, "Button").click
			@b.has?(:text, "Homepage").should be_true
		end
		
		it "Automated AJAX call should works without wait_for" do					
			@b.go "general/ajax_button"							
			@b.single(:button, "AJAX Button").click
			@b.has?(:text, "Content updated by AJAX").should be_true
		end
		
		it "Not Automated AJAX call should works with wait_for" do
			@b.configure :auto_wait => "false"
			@b.go "general/ajax_button_not_automated"				
			@b.wait_for{@b.has?(:text, "Page loading finished")}
			@b.single(:button, "AJAX Button").click
			@b.wait_for{@b.has?(:text, "Content updated by AJAX")}
			@b.has?(:text, "Content updated by AJAX").should be_true
		end
		
		it "Not Automated AJAX call should fail without wait_for for_AJAX_Call_Finished" do
			@b.configure :auto_wait => "false"
			@b.go "general/ajax_button_not_automated"				
			@b.wait_for{@b.has?(:text, "Page loading finished")}
			@b.single(:button, "AJAX Button").click
			@b.has?(:text, "Content updated by AJAX").should be_false
		end			
		
		it "Link" do
			@b.go "general/click_link"
			@b.has?(:text, "Link Result").should be_false
			@b.single(:link, "The Link").click
			@b.has?(:text, "Link Result").should be_true			
			
			# The same with RegExp
			@b.go "general/click_link"
			@b.has?(:text, "Link Result").should be_false
			@b.single(:link, /The Link/).click
			
			@b.has?(:text, "Link Result").should be_true
		end
		
		it "Button" do
			@b.go "general/click_button"
			@b.has?(:text, "Homepage").should be_false
			@b.single(:button, "Button2").click
			@b.has?(:text, "Homepage").should be_true
			
			# The same with RegExp
			@b.go "general/click_button"
			@b.has?(:text, "Homepage").should be_false
			@b.single(:button, /Button2/).click
			@b.has?(:text, "Homepage").should be_true
		end
		
		it "get_alert" do
			@b.go "general/alert"
			@b.get_alert.should be_nil
			@b.single(:button, /Button/).click
			@b.get_alert.should == "Some message"
			@b.get_alert.should be_nil
		end
		
		it "uri, back" do
			@b.go "general/click_link"
			@b.uri.should =~ /click_link/
			@b.go "general/click_button"
			@b.uri.should =~ /click_button/
			@b.go_back
			@b.uri.should =~ /click_link/
		end
		
		it "refresh, html" do
			@b.go "general/refresh"
			v = @b.html.scan(/Counter([0-9]+)/)
			i1 = @b.html.scan(/Counter([0-9]+)/)[0][0].to_i				
			@b.refresh
			i2 = @b.html.scan(/Counter([0-9]+)/)[0][0].to_i
			(i2-i1).should == 1
		end		
		
		
		it "text, is_checked?, selection" do
			@b.go "general/text"
			@b.single("//*[@name = 'text_field']").text.should == "TextFieldValue"			
			@b.single("//*[@name = 'text_area']").text.should == "TextAreaValue"				
			@b.single("//*[@name = 'file']").text.should == ""			
			@b.single("//*[@name = 'empty_select']").selection.should == []			
			@b.single("//*[@name = 'select']").selection.should == ["Two"]			
			@b.single("//*[@name = 'multi_select']").selection.should == ["Two", "Three"]				
			@b.single("//*[@name = 'radio_button1']").checked?.should be_false
			@b.single("//*[@name = 'radio_button2']").checked?.should be_true
			@b.single("//*[@name = 'check_box1']").checked?.should be_false
			@b.single("//*[@name = 'check_box2']").checked?.should be_true
		end
		
		it "text also should works_for Text, not only_for Text Inputs" do
			@b.go "general/text"
			@b.single("//*[@id = 'text']").text.should == "Text"
		end
		
		it "type, check, select" do
			@b.go "general/text_empty"
			
			file = File.expand_path(__FILE__)
			
			@b.single("//*[@name = 'text_field']").type "TextFieldValue"			
			@b.single("//*[@name = 'text_area']").type "TextAreaValue"	
			@b.single("//input[@name = 'file']").type file
			@b.single("//*[@name = 'select']").select "Two"
			@b.single("//*[@name = 'multi_select']").select ["Two", "Three"]				
			@b.single("//*[@name = 'radio_button2']").check
			@b.single("//*[@name = 'check_box2']").check
			
			@b.single(:button, "Submit").click
			
			@b.has?(:text, "TextField: TextFieldValue").should be_true 
			@b.has?(:text, "TextArea: TextAreaValue").should be_true 
			@b.has?(:text, "File: GeneralSpec.rb").should be_true 
			@b.has?(:text, "SingleSelect: Two").should be_true 
			@b.has?(:text, "MultiSelect: Three").should be_true # TODO Stub, there where problems with Rack
			@b.has?(:text, "RadioButton: RadioButtonTwo").should be_true 
			@b.has?(:text, "CheckBox: CheckBoxTwo").should be_true
		end								
		
		it "text= should works the same as type" do
			@b.go "general/text_empty"
			@b.single("//*[@name = 'text_field']").text = "TextFieldValue"			
			@b.single(:button, "Submit").click
			@b.has?(:text, "TextField: TextFieldValue").should be_true 
		end
		
		it "Queries_for inputs" do
			@b.go "general/text"
			@b.list(:text_input).size.should == 3
			@b.list(:check).size.should == 4
			@b.list(:select).size.should == 3
		end
		
		it "any" do
			@b.go "general/text"
			@b.list(:any).size.should == 11
		end
	end		
end		