require "WGUI/web_spec"

module WGUI	
	# Button
	register_wiget "button" do
		counter = 1
		b = Button.new("Button #{counter}") do
			counter += 1
			b.text = "Button #{counter}"
		end
		b
	end
	#start_webserver; join_webserver;
	# Panel
	register_wiget "label" do
		p = Utils::TestPanel.new
		counter = 1
		l = Label.new("Label #{counter}"); p.children << l
		b = Button.new "Label" do
			counter += 1
			l.text = "Label #{counter}"
		end
		p.children << b
		
		b = Button.new "Panel" do
			counter += 1
			l.text = "Label #{counter}"
			p.refresh
		end
		p.children << b
		p
	end
	
	# TextField
	register_wiget "textfield" do
		panel = Utils::TestPanel.new
		panel.children << Label.new("TextField")
		counter = 1
		tf = TextField.new "text 1"; panel.children << tf
		b = Button.new("Submit", tf) do
			counter += 1
			tf.text.should == "text #{counter}"
			counter += 1
			tf.text = "text #{counter}"
		end
		panel.children << b
		panel
	end
	
	# TextArea
	register_wiget "textarea" do
		panel = Utils::TestPanel.new
		panel.children << Label.new("TextArea")
		counter = 1
		ta = TextArea.new("text #{counter}"); panel.children << ta
		b = Button.new("Submit", ta) do
			counter += 1
			ta.text.should == "text #{counter}"
			counter += 1
			ta.text = "text #{counter}"
		end
		panel.children << b
		panel
	end
	
	# Select
	register_wiget "select" do
		panel = Utils::TestPanel.new
		panel.children << Label.new("Select")
		counter = 1
		s = Select.new ["1", "2", "3", "4", "5"]
		panel.children << s
		b = Button.new("Submit", s) do
			counter += 1
			s.selected.should == "#{counter}"
			counter += 1
			s.selected = "#{counter}"
		end
		panel.children << b
		panel
	end
	
	# Select (modify)
	register_wiget "select modify" do
		panel = Utils::TestPanel.new
		panel.children << Label.new("Select")
		s = Select.new ["1", "2", "3", "4", "5"]
		s.selected = "4"
		s.modify = true
		panel.children << s
		b = Button.new("Submit", s) do			
			p s.selected
		end
		panel.children << b
		panel
	end
	
	# Multiselect
	register_wiget "multiselect" do		
		panel = Utils::TestPanel.new
		panel.children << Label.new("MultiSelect")
		counter = 0
		ms = Multiselect.new ["1", "2", "3", "4", "5", "6"]
		panel.children << ms
		b = Button.new("Submit", ms) do
			counter += 1
			ms.selected.should == ["#{counter}", "#{counter+1}"]
			counter += 1
			ms.selected = ["#{counter}", "#{counter+1}"]
		end
		panel.children << b
		panel
	end
	
	register_wiget "select button" do
		panel = Utils::TestPanel.new
		panel.children << Label.new("Select")
		counter = 1
		s = SelectButton.new		
		panel.children << s
		panel.children << (output = Label.new)
		s.selected = "One"
		s.on("One"){output.text = "Text One"}
		s.on("Two"){output.text = "Text Two"}
		panel
	end
	
	register_wiget "multiselect should select multiple items (from error)" do
		warn "Not implemented"
	end
	
	register_wiget "multiselect should correct save empty selection (from error)" do
		warn "Not implemented"
	end
	
	# Multiselect modify
	register_wiget "multiselect modify" do
		panel = Utils::TestPanel.new
		panel.children << Label.new("MultiSelect")
		counter = 0
		ms = Multiselect.new ["1", "2", "3", "4", "5", "6"], ["4", "custom"]
		ms.modify = true
		panel.children << ms
		b = Button.new "Submit", ms do
			p ms.selected
		end
		panel.children << b
		panel
	end
	
	# Checkbox
	register_wiget "checkbox" do
		panel = Utils::TestPanel.new
		cb = Checkbox.new false
		panel.children << cb
		panel.children << Label.new("Checkbox")
		panel.children << (value = Label.new)
		b = Button.new("Check value", cb) do
			value.text = "value=#{cb.selected}"
		end
		panel.children << b
		panel
	end
	
	# Radiobutton
	register_wiget "radiobutton" do
		panel = Utils::TestPanel.new
		counter = 1
		rb = Radiobutton.new ["1", "2", "3", "4", "5"]
		panel.children << rb
		b = Button.new("Submit", rb) do
			counter += 1
			rb.selected.should == "#{counter}"
			counter += 1
			rb.selected = "#{counter}"
		end
		panel.children << b
		panel
	end
	
	#			start_webserver; join_webserver;
	
	describe "Base wigets Collection" do		
		
		it "Button" do
			go "ui?t=button"
			should_have :button, "Button 1"
			click "Button 1"
			should_have :button, "Button 2"
			click "Button 2"
			should_have :button, "Button 3"
		end
		
		it "Label" do
			go "ui?t=label"
			# Label
			should_have "Label 1"
			click "Label"
			should_have "Label 2"
			click "Label"
			should_have "Label 3"
			
			# Utils::TestPanel
			click "Panel"
			should_have "Label 4"
			click "Panel"
			should_have "Label 5"
		end
		
		it "TextField" do
			go "ui?t=textfield"
			should_have :text_input, "text 1"
			attribute_near("TextField").type "text 2"
			click "Submit"
			attribute_near("TextField").text.should == "text 3"
			
			attribute_near("TextField").type "text 4"
			click "Submit"
			attribute_near("TextField").text.should == "text 5"
		end
		
		it "TextArea" do
			go "ui?t=textarea"
			should_have :text_input, "text 1"
			attribute_near("TextArea").type "text 2"
			click "Submit"
			attribute_near("TextArea").text.should == "text 3"
			attribute_near("TextArea").type "text 4"
			click "Submit"
			attribute_near("TextArea").text.should == "text 5"
		end
		
		it "Select" do
			go "ui?t=select"
			attribute_near("Select").selection.should == ["1"]
			attribute_near("Select").select "2"
			click "Submit"
			attribute_near("Select").selection.should == ["3"]			
			attribute_near("Select").select "4"
			click "Submit"
			attribute_near("Select").selection.should == ["5"]
		end
		
		it "Select Button" do
			warn "STUB"
			# TODO It doesnt works becouse UIDriver uses 'select' instead of 'click' and so it doesn't
			# triggers JS listener.
			#					go "ui?t=select button"
			#					attribute_near("Select").selection.should == ["One"]
			#					attribute_near("Select").select "Two"
			#					attribute_near("Select").selection.should == ["Two"]
			#					p browser.has?(:text, "Text Two")
			#					should_have "Text Two"
			#					attribute_near("Select").select "One"
			#					attribute_near("Select").selection.should == ["One"]
			#					should_have "Text One"
		end
		
		it "Select (modify)" do
			go "ui?t=select"
			attribute_near("Select").selection.should == ["1"]
			attribute_near("Select").select "2"
			click "Submit"
			attribute_near("Select").selection.should == ["3"]
			
			attribute_near("Select").select "4"
			click "Submit"
			attribute_near("Select").selection.should == ["5"]
		end												
		
		it "Multiselect" do
			go "ui?t=multiselect"
			attribute_near("MultiSelect") == []
			attribute_near("MultiSelect").select ["1", "2"]
			click "Submit"					
			attribute_near("MultiSelect").selection.should == ["2", "3"]
			
			attribute_near("MultiSelect").select ["3", "4"]				
			click "Submit"
			attribute_near("MultiSelect").selection.should == ["4", "5"]
		end
		
		it "Checkbox" do
			go "ui?t=checkbox"
			attribute_near("Checkbox").checked?.should be_false
			attribute_near("Checkbox").check
			click "Check value"
			should_have "value=true"
			
			attribute_near("Checkbox").check false
			click "Check value"
			should_have "value=false"
		end
		
		it "Radiobutton" do
			go "ui?t=radiobutton"
			attribute_near("1").checked?.should be_false
			attribute_near("2").check
			click "Submit"
			attribute_near("3").checked?.should be_true
			
			attribute_near("4").check
			click "Submit"
			attribute_near("5").checked?.should be_true
		end
		
		#			start_webserver; join_webserver;
	end
end
