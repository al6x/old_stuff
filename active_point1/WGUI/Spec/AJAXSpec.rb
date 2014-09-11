require 'WGUI//web_spec'

module WGUI
	register_wiget "Should correct works when response is empty" do
		Button.new "Empty responce"
	end

	register_wiget "Should correct works with exception" do
		p = Button.new "Failed" do
			sleep 1
			raise "Testing exception (it's ok, it should be raised)."
		end
		p
	end

	register_wiget "Should refresh only Components that where marked with refresh method but not others" do
		p = Utils::TestPanel.new
		p.children << (one = Label.new "One")
		p.children << (two = Label.new "Two")
		p.children << (three = Label.new "Three")
		p.children << (Button.new "Refresh" do
				one.text = "new One"
				two.text = "new Two"
				two.refresh = false
				three.text = "new Three"
			end)
		p
	end

	register_wiget "Should refresh all Childs of refreshed Component" do
		p = Utils::TestPanel.new
		p.children << (p2 = Utils::TestPanel.new)
		p2.children << (one = Label.new "One")
		p2.children << (two = Label.new "Two")
		p.children << (three = Label.new "Three")
		p.children << (Button.new "Refresh" do
				one.text = "new One"
				one.refresh = false
				two.text = "new Two"
				two.refresh = false
				three.text = "new Three"
				three.refresh = false

				p2.refresh
			end)
		p
	end

	register_wiget "Should get input values only from Input Components inside specified Container but not others" do
		p = Utils::TestPanel.new
		p.children << (p2 = Utils::TestPanel.new)
		p2.children << (Label.new 'Value1')
		p2.children << (v1 = TextField.new)
		p2.children << (Label.new 'Value2')
		p2.children << (v2 = TextField.new)
		p.children << (Label.new 'Value3')
		p.children << (v3 = TextField.new)
		p.children << (l = Label.new '')
#		clicked = false
		p.children << (Button.new 'Get Values', p2 do
#				clicked = true
				v1.text.should == 'value 1'
				v2.text.should == 'value 2'
				v3.text.should == ''

				l.text = 'Values are collected!'
			end)
		p
	end

	register_wiget "Should get input values only from specified Input Components but not others" do
		p = Utils::TestPanel.new
		p.children << (Label.new 'Value1')
		p.children << (v1 = TextField.new )
		p.children << (Label.new  'Value2')
		p.children << (v2 = TextField.new )
		p.children << (Label.new 'Value3')
		p.children << (v3 = TextField.new )
		p.children << (l = Label.new  '')
#		clicked = false
		p.children << (Button.new 'Get Values', [v1, v2] do
#				clicked = true

				v1.text.should == 'value 1'
				v2.text.should == 'value 2'
				v3.text.should == ''

				l.text = 'Values are collected!'
			end)
		p
	end

	register_wiget "Should refresh only Components and Containers marked with refresh method but not others" do
		p = Utils::TestPanel.new
		p.children << (p2 = Utils::TestPanel.new)
		p2.children << (l1 = Label.new 'Label1')
		p2.children << (l2 = Label.new 'Label2')
		p.children << (l3 = Label.new 'Label3')
		p.children << (l4 = Label.new 'Label4')
		p.children << (Button.new 'Get Values' do
				l1.text = 'New Label 1'
				l2.text = 'New Label 2'
				l3.text = 'New Label 3'
				l4.text = 'New Label 4'
				l4.refresh = false

				p2.refresh
				l3.refresh
			end)
		p
	end

	describe "AJAX" do
		it 'Should correct works when response is empty' do
			go 'localhost:8080/?t=Should correct works when response is empty'
			click 'Empty responce'
			sleep 0.5
		end
		
		it "Should correct works with exception" do
			#			Temporary disabled. There is no currently ability to check HOWT for alerts.
			#			go 'localhost:8080'
			#			click 'Failed'
			#			wait_for.should have_text('Operation failed!')
		end
		
		it "Should refresh only Components that where marked with refresh method but not others" do		
			go 'localhost:8080/?t=Should refresh only Components that where marked with refresh method but not others'
			wait_for.should have_text('One')
			wait_for.should have_text('Two')
			wait_for.should have_text('Three')
			click 'Refresh'
			wait_for.should have_text('new One')
			wait_for{!has_text?('new Two')}
			wait_for.should have_text('new Three')
		end
	
		it "Should refresh all Childs of refreshed Component" do		
			go 'localhost:8080/?t=Should refresh all Childs of refreshed Component'
			wait_for.should have_text('One')
			wait_for.should have_text('Two')
			wait_for.should have_text('Three')
			click 'Refresh'
			wait_for.should have_text('new One')
			wait_for.should have_text('new Two')
			wait_for{!has_text?('new Three')}
		end
  
		it "Should get input values only from Input Components inside specified Container but not others" do		
			go 'localhost:8080/?t=Should get input values only from Input Components inside specified Container but not others'
			type 'Value1' => 'value 1'
			type 'Value2' => 'value 2'
			type 'Value3' => 'value 3'
			click 'Get Values'		
			wait_for.should have_text('Values are collected!')
#			clicked.should be_true
		end
  			
		it "Should get input values only from specified Input Components but not others" do					
			go 'localhost:8080/?t=Should get input values only from specified Input Components but not others'
			type 'Value1' => 'value 1'
			type 'Value2' => 'value 2'
			type 'Value3' => 'value 3'
			click 'Get Values'		
			wait_for.should have_text('Values are collected!')
#			clicked.should be_true
		end
	
		it "Should refresh only Components and Containers marked with refresh method but not others" do					
			go 'localhost:8080/?t=Should refresh only Components and Containers marked with refresh method but not others'
			click 'Get Values'
			wait_for.should have_text('New Label 1')
			wait_for.should have_text('New Label 2')
			wait_for.should have_text('New Label 3')
			wait_for{!has_text?('New Label 4')}
		end				
	end
end