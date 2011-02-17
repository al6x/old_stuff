require 'WGUI/web_spec'

module WGUI
	register_wiget "Web resources" do
		file_name = File.join(File.dirname(__FILE__), 'data', 'file.txt')
		data = Core::IO::ResourceData.initialize_from_file(file_name)
		res = WResource.new(data)
		res.open_in_the_same_window = true
		res
	end

	register_wiget "should display image" do
		file_name = File.join(File.dirname(__FILE__), 'data', 'iron.jpg')
		data = Core::IO::ResourceData.initialize_from_file(file_name)
		WImage.new(data)
	end

	register_wiget "should upload file" do
		dir = File.dirname(__FILE__)
		panel = Utils::TestPanel.new
		panel.children << (l = Label.new "Enter file path")
		panel.children << (upload = FileUpload.new)
		panel.children << (Button.new "Upload", upload do
				#                    upload.size.should == File.size(File.join(dir, 'data', 'iron.jpg'))
				File.open(File.join(dir, 'data', "2#{upload.resource_id}"), 'wb') do|out|
					upload.file.each{|part| out.write part} unless upload.empty?
				end
				l.text = 'File has been uploaded!'
				l.refresh
			end)
		panel.children << (Button.new "Reset" do
				l.text = "Enter file path"
				l.refresh
			end)
		panel
	end

	register_wiget "Should not raise error if invalid file path" do
		dir = File.dirname(__FILE__)
		begin File.delete(File.join(dir, 'data', '2iron.jpg')) rescue Exception; end

		panel = Utils::TestPanel.new
		panel.children << (l = Label.new "Enter file path")
		panel.children << (upload = FileUpload.new)
		panel.children << (Button.new "Upload", upload do
				l.text = "File is empty!" if upload.empty?
				l.refresh
			end)
		panel
	end

	register_wiget "Should upload two files simultaneously" do
		dir = File.dirname(__FILE__)

		panel = Utils::TestPanel.new
		panel.children << (Label.new "File 1")
		panel.children << (upload1 = FileUpload.new)
		panel.children << (Label.new "File 2")
		panel.children << (upload2 = FileUpload.new)
		panel.children << (status = Label.new "")
		panel.children << (Button.new "Upload", [upload1, upload2] do
				File.open(File.join(dir, 'data', "2#{upload1.resource_id}"), 'wb'){|out|
					upload1.file.each{|part| out.write part} unless upload1.empty?
				}
				File.open(File.join(dir, 'data', "2#{upload2.resource_id}"), 'wb'){|out|
					upload2.file.each{|part| out.write part} unless upload2.empty?
				}
				status.text = "Upload finished"
				status.refresh
			end)
		panel
	end

	register_wiget "file should correct works without resource" do
		WResource.new(nil)
	end

	register_wiget "image should correct works without resource" do
		WImage.new(nil)
	end

	register_wiget "should correct display two images one with data and another without" do
		file_name = File.join(File.dirname(__FILE__), 'data', 'iron.jpg')
		panel = Utils::TestPanel.new
		panel.children << (WImage.new nil)
		data = Core::IO::ResourceData.initialize_from_file(file_name)
		panel.children << (WImage.new data)
		panel.children << (WImage.new nil)
		panel
	end

	register_wiget "should correct submit panel with many fields and file" do
		dir = File.dirname(__FILE__)

		panel = Utils::TestPanel.new

		panel.children << (Label.new "Enter file path")
		panel.children << (upload = FileUpload.new)

		panel.children << (Label.new "TextField")
		panel.children << (tf = TextField.new "some text")

		panel.children << (Button.new "Upload", panel do
				File.open(File.join(dir, 'data', "2#{upload.resource_id}"), 'wb'){|out|
					upload.file.each{|part| out.write part} unless upload.empty?
				}

				tf.text.should == 'new value'
				tf.text = 'confirmed'
				tf.refresh
			end)
		panel
	end
                #start_webserver; join_webserver;
	describe "Web resources" do				
		it "should allow load file" do
			go 'localhost:8080/ui?t=Web resources'
			click 'file.txt'
			wait_for{html =~ /File for test/}
		end

		it "should display image" do
			go 'localhost:8080/ui?t=should display image'
		end

		it "should upload file" do
			dir = File.dirname(__FILE__)
			begin File.delete(File.join(dir, 'data', '2iron.jpg')) rescue Exception; end

			go 'localhost:8080/ui?t=should upload file'
			type :text => File.join(dir, 'data', 'iron.jpg'), :nearest_to => "Enter file path"
			click(/Upload/)
			wait_for.should have_text('File has been uploaded!')

			# Try second time, should upload one after another
			click "Reset"
			type :text => File.join(dir, 'data', 'iron.jpg'), :nearest_to => "Enter file path"
			click(/Upload/)
			wait_for.should have_text('File has been uploaded!')

			File.exist?(File.join(dir, 'data', '2iron.jpg')).should be_true
			File.size(File.join(dir, 'data', '2iron.jpg')).should == File.size(File.join(dir, 'data', 'iron.jpg'))
			File.delete(File.join(dir, 'data', '2iron.jpg'))
		end

		it "Should not raise error if invalid file path" do
			go "localhost:8080/ui?t=Should not raise error if invalid file path"
			type :text => '', :nearest_to => "Enter file path"
			click(/Upload/)
			wait_for.should have_text(/File is empty/)
		end

		it "Should upload two files simultaneously" do
			dir = File.dirname(__FILE__)
			begin File.delete(File.join(dir, 'data', '2iron.jpg')) rescue Exception; end

			go 'localhost:8080/ui?t=Should upload two files simultaneously'
			type "File 1" => File.join(dir, 'data', 'iron.jpg')
			type "File 2" => File.join(dir, 'data', 'file.txt')
			click(/Upload/)
			wait_for.should have_text('Upload finished')

			File.exist?(File.join(dir, 'data', '2iron.jpg')).should be_true
			File.size(File.join(dir, 'data', '2iron.jpg')).should == File.size(File.join(dir, 'data', 'iron.jpg'))
			File.delete(File.join(dir, 'data', '2iron.jpg'))

			File.exist?(File.join(dir, 'data', '2file.txt')).should be_true
			File.size(File.join(dir, 'data', '2file.txt')).should == File.size(File.join(dir, 'data', 'file.txt'))
			File.delete(File.join(dir, 'data', '2file.txt'))
		end

		it 'file should correct works without resource' do
			go 'localhost:8080/ui?t=file should correct works without resource'
		end

		it "image should correct works without resource" do
			go 'localhost:8080/ui?t=image should correct works without resource'
		end

		it "should correct display two images one with data and another without" do
			go 'localhost:8080/ui?t=should correct display two images one with data and another without'
		end

		it "should correct works with static resource" do
			dir = File.dirname __FILE__
			Scope[Engine::StaticResource].add_file "test_file.txt", "#{dir}/data/test_file.txt"
			go "localhost:8080/#{WGUI.static_resource_uri 'test_file.txt'}"
			html.should =~ /File for test/
		end
		
		it "should correct submit panel with many fields and file" do
			dir = File.dirname(__FILE__)
			begin File.delete(File.join(dir, 'data', '2iron.jpg')) rescue Exception; end							

			go 'localhost:8080/ui?t=should correct submit panel with many fields and file'
			wait_for.should have_the(:textfield => "some text")
            type :text => 'new value', :from_right_of => "TextField"
			type :text => File.join(dir, 'data', 'iron.jpg'), :from_right_of => "Enter file path"
            sleep 5
			click(/Upload/)		
			wait_for{text(:nearest_to => "TextField") == "confirmed"}		
				
			File.exist?(File.join(dir, 'data', '2iron.jpg')).should be_true
			File.size(File.join(dir, 'data', '2iron.jpg')).should == File.size(File.join(dir, 'data', 'iron.jpg'))
			File.delete(File.join(dir, 'data', '2iron.jpg'))
		end
	end
end