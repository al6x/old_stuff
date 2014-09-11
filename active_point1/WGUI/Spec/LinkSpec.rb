require 'WGUI/web_spec'

module WGUI
	module LinkSpec
		class RootComponent < WComponent
			include WPortlet
			children :content
			attr_accessor :content
		end

		register_wiget "link_for_root" do
			root = RootComponent.new
			root.content = Link.new 'link', {'name' => 'value'}
			root
		end

		register_wiget "link for delete state" do
			root = RootComponent.new
			root.component_id = 'root'
			root.content = Link.new('link') do |state|
				state.delete 'name1';
				state
			end
			root
		end

		register_wiget "Empty link" do
			root = RootComponent.new
			root.component_id = 'root'
			root.content = Link.new('link')
			root
		end

		class InnerComponent < WComponent
			include WPortlet
			children :content
			attr_accessor :content
		end

		register_wiget "link_for_inner_WPortlet" do
			root = RootComponent.new.set(:component_id => :root)
			root.content = (inn = InnerComponent.new.set(:component_id =>:inn))
			inn.content = (Link.new 'link', {'one' => 'two'})
			root
		end

		register_wiget "Should_correct_displays_after_AJAX_call" do
			root = RootComponent.new
			link = Link.new('link', {'name' => 'value'})
			button = Button.new('AJAX') do
				root.content << link
				root.refresh
			end
			root.content = [button]
			root
		end
		
		register_wiget "link outside portlet" do
			raise "Add HOWT section for this test!"
			panel = Utils::TestPanel.new
			portlet = RootComponent.new
			panel.children << portlet
			
			link = Link.new('link', {'name' => 'value'})
			link.portlet = portlet
			panel.children << link

			panel
		end
		
#		start_webserver; join_webserver;

		describe "Link" do

			it "link for root" do
				go 'localhost:8080/?t=link_for_root'
				wait_for.should have_the(:link => 'link')
				click 'link'
				wait_for{uri =~ /name\/value/}
			end
		
			it "link for delete state" do
				go 'localhost:8080/?t=link for delete state&root=name1/value1/name2/value2'
				wait_for.should have_the(:link => 'link')
				uri.should =~ /name1\/value1\/name2\/value2/
				click 'link'
				wait_for{uri =~ /name2\/value2/}
				wait_for{uri !~ /name1\/value1/}
			end
	
			it "Empty link" do
				go 'localhost:8080/?t=Empty link&root=name1/value1/name2/value2'
				wait_for.should have_text('link')
				should_not have_the(:link => 'link')
				uri.should =~ /name1\/value1\/name2\/value2/
			end
		
			it "link for inner WPortlet" do
				go 'localhost:8080/?t=link_for_inner_WPortlet&root=name/value'
				wait_for{uri =~ /root=name\/value/}
				wait_for{uri !~ /inn=one\/two/}
				click 'link'
				wait_for{uri =~ /inn=one\/two.+root=name\/value/}
			end
        
			it "Should correct displays after AJAX call (case from error)" do
				go 'localhost:8080/?t=Should_correct_displays_after_AJAX_call'
				click 'AJAX'
				wait_for.should have_the(:link => 'link')
			end
		end
	end
end