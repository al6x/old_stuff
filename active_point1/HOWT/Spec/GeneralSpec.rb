require 'howt/howt'
require 'spec'

include HOWT::BrowserHelper
module HOWT	
	module BrowserSpec				
		describe 'General specification' do		
			after :all do close end					
			it "has_text?" do
				go 'localhost:7000/has_text'
										
				should have_text('Text');
				should have_text('Link')		
				should have_text('Button')				
				should have_text('TextField')
				should have_text('TextArea')												
				should have_text('Select')
				should have_text('MultiSelect')
																	
				should_not have_text('Text1')
				should_not have_text("Button1")		

				# The same but with RegExp
				should have_text(/Text/);
				should have_text(/Link/)	
	
				should have_text(/Button/)				
				should have_text(/TextField/)
				should have_text(/TextArea/)												
				should have_text(/Select/)
				should have_text(/MultiSelect/)
																	
				should_not have_text(/Text1/)
				should_not have_text(/Button1/)
			end
			
			it "should correct works with tag <button>" do
				go 'localhost:7000/button_tag'				
				should_not have_the(:text => 'Button')
				click 'Button'
				wait_for.should have_text('Homepage')
            end
						
			it "click" do
				go 'localhost:7000/click_link'
				should_not have_text('Homepage')
				click 'The Link'
				wait_for.should have_text('Homepage')
										
				go 'localhost:7000/click_button'
				should_not have_text('Homepage')
				click 'Button2'
				wait_for.should have_text('Homepage')
							
				go "localhost:7000/click_fuzzy"
				should_not have_text('Fuzzy Button clicked')
				click :button => "Button", :from_right_of => "Button 2"
				wait_for.should have_text("Fuzzy Button clicked")
										
				go "localhost:7000/click_fuzzy"
				should_not have_text('Fuzzy Link clicked')
				click :link => "Fuzzy link", :from_right_of => "Link 2"
				wait_for.should have_text("Fuzzy Link clicked")
				
				# The same but with RegExp
				go "localhost:7000/click_link"
				should_not have_text(/Homepage/)
				click(/The Link/)
				wait_for.should have_text(/Homepage/)
										
				go "localhost:7000/click_button"
				should_not have_text(/Homepage/)
				click(/Button2/)
				wait_for.should have_text(/Homepage/)
							
				go "localhost:7000/click_fuzzy"
				should_not have_text(/Fuzzy Button clicked/)
				click :button => /Button/, :from_right_of => /Button 2/
				wait_for.should have_text(/Fuzzy Button clicked/)
										
				go "localhost:7000/click_fuzzy"
				should_not have_text(/Fuzzy Link clicked/)
				click :link => /Fuzzy link/, :from_right_of => /Link 2/
				wait_for.should have_text(/Fuzzy Link clicked/)
			end
						
			it "have_element" do
				go 'localhost:7000/click_link'
				should_not have_element('Invalid name')
				should have_the(:link => 'The Link') # same as have_element
										
				go 'localhost:7000/click_button'				
				should have_element(:button => 'Button2')
				
				# The same but with RegExp
				go "localhost:7000/click_link"
				should_not have_element(/Invalid name/)
				should have_element(/Link/)
										
				go "localhost:7000/click_button"
				should have_element(/Button2/)
			end			
						
			it "uri, back" do
				go 'localhost:7000/click_link'
				uri.should =~ /click_link/
				go 'localhost:7000/click_button'
				uri.should =~ /click_button/
				go_back
				uri.should =~ /click_link/
			end
			
			it "refresh, html" do
				go 'localhost:7000/refresh'
				wait_for{html =~ /body/}
				i1 = html.scan(/[0-9]+/)[0].to_i				
				refresh
				wait_for{html !~ /#{i1}/}
				i2 = html.scan(/[0-9]+/)[0].to_i
				(i2-i1).should == 1
			end
			
			it "String equality" do				
				go "localhost:7000/string_equality"				
				click :link => "Link", :from_right_of => "Label"

				go "localhost:7000/string_equality"
				lambda { 
					click :link => /Link/, :from_right_of => /Label/
				}.should raise_error(RuntimeError, /Found more than one Text Elements/)
			end
						
			it "text, is_checked?, selection" do
				go 'localhost:7000/text'
				text("TextField").should == "TextFieldValue"
				text(:from_right_of => "TextField").should == "TextFieldValue"
							
				text("TextArea").should == "TextAreaValue"				
				text(:from_right_of => "TextArea").should == "TextAreaValue"
							
				selection('SingleSelect').should == ['Two']
				selection(:from_right_of => 'SingleSelect').should == ['Two']
							
				selection('MultiSelect').should == ['Two', 'Three']				
				selection(:from_right_of => 'MultiSelect').should == ['Two', 'Three']
							
				should_not be_checked("RadioButtonOne")
				should be_checked('RadioButtonTwo')
				should_not be_checked(:from_left_of => "RadioButtonOne")
				should be_checked(:from_left_of => 'RadioButtonTwo')
							
				should_not be_checked('CheckBoxOne')
				should be_checked('CheckBoxTwo')
				should be_checked('CheckBoxThree')
				should_not be_checked(:from_left_of => 'CheckBoxOne')
				should be_checked(:from_left_of => 'CheckBoxTwo')
				should be_checked(:from_left_of => 'CheckBoxThree')
				
				# The same but with RegExp
				go "localhost:7000/text"
				text(/TextField/).should == "TextFieldValue"
				text(:from_right_of => /TextField/).should == "TextFieldValue"
							
				text(/TextArea/).should == "TextAreaValue"				
				text(:from_right_of => /TextArea/).should == "TextAreaValue"
							
				selection(/SingleSelect/).should == ["Two"]
				selection(:from_right_of => /SingleSelect/).should == ["Two"]
							
				selection(/MultiSelect/).should == ["Two", "Three"]				
				selection(:from_right_of => /MultiSelect/).should == ["Two", "Three"]
							
				should_not be_checked(/RadioButtonOne/)
				should be_checked(/RadioButtonTwo/)
				should_not be_checked(:from_left_of => /RadioButtonOne/)
				should be_checked(:from_left_of => /RadioButtonTwo/)
							
				should_not be_checked(/CheckBoxOne/)
				should be_checked(/CheckBoxTwo/)
				should be_checked(/CheckBoxThree/)
				should_not be_checked(:from_left_of => /CheckBoxOne/)
				should be_checked(:from_left_of => /CheckBoxTwo/)
				should be_checked(:from_left_of => /CheckBoxThree/)
			end
			
			it "type, check, select" do
				go 'localhost:7000/form'
				
				type "TextField" => "TextFieldValue"
				type :text => "TextFieldValue", :from_right_of => "TextField"
								
				type "TextArea" => "TextAreaValue"
				type :text => "TextAreaValue", :from_right_of => "TextArea"
								
				type "FileInput" => "c:\\FileInputValue"
				type :text => "c:\\FileInputValue", :from_right_of => "FileInput"
				
				select 'SingleSelect' => 'Three'
				select :option => 'Two', :from_right_of => "SingleSelect"
				
				select 'MultiSelect' => ['One']
				unselect 'MultiSelect'
				unselect :from_right_of => 'MultiSelect'
				select :option => ['Two', 'Three'], :from_right_of => 'MultiSelect'
				
				check 'RadioButtonTwo'
				check :from_left_of => 'RadioButtonTwo'
								
				check 'CheckBoxTwo'
				check :from_left_of => 'CheckBoxTwo'
								
				check 'CheckBoxThree'
				check :from_left_of => 'CheckBoxThree'
				
				click 'Submit'
				
				wait_for.should have_text('TextField: TextFieldValue')
				should have_text('TextArea: TextAreaValue')
				should have_text('FileInput: FileInputValue')
				should have_text('SingleSelect: Two')
				should have_text('MultiSelect: TwoThree')
				should have_text('RadioButton: RadioButtonTwo')
				should have_text('CheckBox: CheckBoxTwoCheckBoxThree')
				
				# The same but with RegExp
				go "localhost:7000/form"
				
				type(/TextField/ => "TextFieldValue")
				type :text => "TextFieldValue", :from_right_of => /TextField/
								
				type(/TextArea/ => "TextAreaValue")
				type :text => "TextAreaValue", :from_right_of => /TextArea/
								
				type(/FileInput/ => "c:\\FileInputValue")
				type :text => "c:\\FileInputValue", :from_right_of => /FileInput/
				
				select(/SingleSelect/ => "Three")
				select :option => "Two", :from_right_of => /SingleSelect/
				
				select(/MultiSelect/ => ["One"])
				unselect(/MultiSelect/)
				unselect :from_right_of => /MultiSelect/
				select :option => ["Two", "Three"], :from_right_of => /MultiSelect/
				
				check(/RadioButtonTwo/)
				check :from_left_of => /RadioButtonTwo/
								
				check(/CheckBoxTwo/)
				check :from_left_of => /CheckBoxTwo/
								
				check(/CheckBoxThree/)
				check :from_left_of => /CheckBoxThree/
				
				click(/Submit/)
				
				wait_for.should have_text(/TextField: TextFieldValue/)
				should have_text(/TextArea: TextAreaValue/)
				should have_text(/FileInput: FileInputValue/)
				should have_text(/Select: Two/)
				should have_text(/MultiSelect: TwoThree/)
				should have_text(/RadioButton: RadioButtonTwo/)
				should have_text(/CheckBox: CheckBoxTwoCheckBoxThree/)
            end
			
			it "Should correct works with JavaScript Errors" do
				go "localhost:7000/errors"
				
				lambda { 
					click :link => "Link", :from_right_of => "Label"
				}.should raise_error(RuntimeError, /Found more than one Text Elements/)
				
				# The same but with RegExp
				lambda { 
					click :link => /Link/, :from_right_of => /Label/
				}.should raise_error(RuntimeError, /Found more than one Text Elements/)
            end
			
			it "scope" do		
				go 'localhost:7000/scope'
				count(/The Text/).should == 9
				
				scope :left => [:text, 'scopeleft'], :right => [:text, 'scoperight'], 
					:top => [:text, /scopetop/], :bottom => [:text, /scopebottom/]
				count('The Text').should == 1
				
				lambda {
					scope 'Central Cell'
                }.should raise_error				
				scope :name => 'Central Cell', :left => 'scopeleft', :right => 'scoperight', 
					:top => 'scopetop', :bottom => 'scopebottom'
				
				scope :left => 'scopeleft', :right => 'scoperight'
				count('The Text').should == 3
				
				clear_scope
				count('The Text').should == 9
				
				scope 'Central Cell'
				count('The Text').should == 1
				
				check 'Checkbox'
				click 'Submit'
				clear_scope
				should have_text('checkbox')
            end
			
			it "Waiting for AJAX refresh" do
				go 'localhost:7000/wait_for'
				should_not have_text('Something')
				wait_for(5).should have_text('Something')
				
				refresh
				should_not have_text('Something')
				wait_for(5){has_text?('Something')}
            end
		end		
	end		
end
