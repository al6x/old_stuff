require 'WGUI/web_spec'

module WGUI	
	# Button
	register_wiget "button" do
#		fuck
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
		s = Select.new ['1', '2', '3', '4', '5']
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
		s = Select.new ['1', '2', '3', '4', '5']
		s.selected = '4'
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
		ms = Multiselect.new ['1', '2', '3', '4', '5', '6']
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
	
	# Multiselect modify
	register_wiget "multiselect modify" do
		panel = Utils::TestPanel.new
		panel.children << Label.new("MultiSelect")
		counter = 0
		ms = Multiselect.new ['1', '2', '3', '4', '5', '6'], ['4', 'custom']
		ms.modify = true
		panel.children << ms
		b = Button.new("Submit", ms) do
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
		panel.children << Label.new('Checkbox')
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
		rb = Radiobutton.new ['1', '2', '3', '4', '5']
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
	
#	start_webserver; join_webserver;
	
	describe "Base wigets Collection" do
		it "Button" do
			go 'localhost:8080/?t=button'
			wait_for.should have_the(:button => "Button 1")
			click("Button 1")
			wait_for.should have_the(:button => "Button 2")
			click("Button 2")
			wait_for.should have_the(:button => "Button 3")
		end

		it "Label" do
			go 'localhost:8080/?t=label'
			# Label
			wait_for.should have_text('Label 1')
			click "Label"
			wait_for.should have_text('Label 2')
			click "Label"
			wait_for.should have_text('Label 3')

			# Utils::TestPanel
			click "Panel"
			wait_for.should have_text('Label 4')
			click "Panel"
			wait_for.should have_text('Label 5')
		end

		it "TextField" do
			go 'localhost:8080/?t=textfield'
			wait_for.should have_the(:textfield => "text 1")
			type :text => 'text 2', :nearest_to => "TextField"
			click 'Submit'
			wait_for{text(:nearest_to => "TextField") == "text 3"}

			type :text => 'text 4', :nearest_to => "TextField"
			click 'Submit'
			wait_for{text(:nearest_to => "TextField") == "text 5"}
		end

		it "TextArea" do
			go 'localhost:8080/?t=textarea'
			wait_for.should have_the(:textarea => "text 1")
			type :text => 'text 2', :nearest_to => "TextArea"
			click "Submit"
			wait_for{text(:nearest_to => "TextArea") == 'text 3'}

			type :text => 'text 4', :nearest_to => "TextArea"
			click "Submit"
			wait_for{text(:nearest_to => "TextArea") == 'text 5'}
		end

		it "Select" do
			go 'localhost:8080/?t=select'
			wait_for{selection(:nearest_to => 'Select') == ['1']}
			select :option => ['2'], :nearest_to => 'Select'
			click 'Submit'
			wait_for{selection(:nearest_to => 'Select') == ['3']}

			select :option => ['4'], :nearest_to => 'Select'
			click 'Submit'
			wait_for{selection(:nearest_to => 'Select') == ['5']}
		end
		
#		it "Select (modify)" do
#			go 'localhost:8080/?t=select'
#			wait_for{selection(:nearest_to => 'Select') == ['1']}
#			select :option => ['2'], :nearest_to => 'Select'
#			click 'Submit'
#			wait_for{selection(:nearest_to => 'Select') == ['3']}
#
#			select :option => ['4'], :nearest_to => 'Select'
#			click 'Submit'
#			wait_for{selection(:nearest_to => 'Select') == ['5']}
#		end
    
		it "Multiselect" do
			go 'localhost:8080/?t=multiselect'
			wait_for{selection(:nearest_to => "MultiSelect") == []}
			select :option => ['1', '2'], :nearest_to => 'MultiSelect'
			click 'Submit'
			wait_for{selection(:nearest_to => 'MultiSelect') == ['2', '3']}
		
			select :option => ['3', '4'], :nearest_to => 'MultiSelect'
		
			click 'Submit'
			wait_for{selection(:nearest_to => 'MultiSelect') == ['4', '5']}
		end
    
		it "Checkbox" do
			go 'localhost:8080/?t=checkbox'
			wait_for{!checked?('Checkbox')}
			check 'Checkbox'
			click 'Check value'
			wait_for{has_text?('value=true')}
			
			uncheck 'Checkbox'
			click 'Check value'
			wait_for{has_text?('value=false')}
		end

		it "Radiobutton" do
			go 'localhost:8080/?t=radiobutton'
			wait_for{!checked?(:nearest_to => '1')}
			check '2'
			click 'Submit'
			wait_for.should be_checked('3')

			check '4'
			click 'Submit'
			wait_for.should be_checked('5')
		end
#			start_webserver; join_webserver;
	end
end










