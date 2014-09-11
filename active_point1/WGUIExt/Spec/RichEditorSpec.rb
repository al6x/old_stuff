require 'WGUI/web_spec'
require 'WGUIExt/require'

module WGUI
	register_wiget "Should be able loaded dynamically \
(dynamically added import_scripts with redirect)" do
		p = Utils::TestPanel.new
		p.children << Button.new("Show RichText"){
			data = WGUIExt::RichText::RTData.new("Some data")
			p.children << WGUIExt::RichText::Editor.new(data)
			p.refresh
		}		
		p
	end
	
	register_wiget "HTML output and RichText::View" do
		dir = File.join(File.dirname(__FILE__), 'richeditor');
		file_name = File.join(dir, 'lolww.gif')		
		resources = [Core::IO::ResourceData.initialize_from_file(file_name)]
		
		data = WGUIExt::RichText::RTData.new "Some data", resources
		
		e = WGUIExt::RichText::Editor.new data
		e.on_add do |upload|
			unless upload.empty?
				fname = File.join(dir, upload.resource_id)
				File.open(fname, 'wb') do |out|
					upload.file.each{|part| out.write part}
				end
				data.resources << Core::IO::ResourceData.initialize_from_file(fname)
			end
		end
		e.on_delete do |resource_data|
			data.resources.delete resource_data
		end
		
		v = WGUIExt::RichText::View.new data
		b = Button.new "Refresh", e do
			e.save
			v.refresh
		end
		
		p = Utils::TestPanel.new
		p.box = true
		p.children << e		
		p.children << v
		p.children << b
		p
	end
	
	register_wiget "rich_editor, multiple instances, textareas" do		
		dir = File.join(File.dirname(__FILE__), 'richeditor');
		file_name = File.join(dir, 'lolww.gif')				
		
		begin
			resources = [Core::IO::ResourceData.initialize_from_file(file_name)]				
			data = WGUIExt::RichText::RTData.new "Some data", resources
			e = WGUIExt::RichText::Editor.new data
			e.on_add do |upload|
				unless upload.empty?
					fname = File.join(dir, upload.resource_id)
					File.open(fname, 'wb') do |out|
						upload.file.each{|part| out.write part}
					end
					data.resources << Core::IO::ResourceData.initialize_from_file(fname)
				end
			end
			e.on_delete do |resource_data|
				data.resources.delete resource_data
			end
		end
		
		
		p = Utils::TestPanel.new
		p.box = true
		p.children << TextArea.new
		p.children << e				
		
		begin
			resources2 = [Core::IO::ResourceData.initialize_from_file(file_name)]
			data2 = WGUIExt::RichText::RTData.new "Some data2", resources2
			e2 = WGUIExt::RichText::Editor.new data2
			e2.on_add do |upload|
				unless upload.empty?
					fname = File.join(dir, upload.resource_id)
					File.open(fname, 'wb') do |out|
						upload.file.each{|part| out.write part}
					end
					data2.resources << Core::IO::ResourceData.initialize_from_file(fname)
				end
			end
			e2.on_delete do |resource_data|
				data2.resources.delete resource_data
			end
		end
		
		p.children << TextArea.new
		p.children << e2
		
		p
	end
	start_webserver
	join_webserver
	
	#	describe "Base wigets Collection" do
	#		it "Multiple editors" do
	#            panel = Utils::TestPanel.new
	#            ra = WGUIExt::RichText::RichText.new "Value in first editor"
	#            panel.children << (l = Label.new)
	#            panel.children << TextArea.new
	#            panel.children << (WGUIExt::RichText::RichText.new "")
	#
	#			panel.children << (Button.new "Save", ra do
	#					sleep 1
	#					Log.error "'#{ra.text}''"
	#					l.text = "Edited: #{ra.text}"
	#				end)
	#
	#            panel.children << (Button.new "Show" do
	#					panel.ra = ra
	#					panel.refresh
	#				end)
	#
	#            panel.children << (Button.new "Hide" do
	#					panel.ra = nil
	#					panel.refresh
	#				end)
	#
	#			set_wiget panel
	#
	#            sleep 10000
	#		end
	#
	#        it "Shouldn't interfere with other textareas and richeditors" do
	#
	#        end
	#
	#        it "Shouldn't interfere with iframe file upload" do
	#
	#        end
	#	end
end