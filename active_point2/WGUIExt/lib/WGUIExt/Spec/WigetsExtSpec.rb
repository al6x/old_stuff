require 'WGUI/web_spec'
require 'WGUIExt/require'

module WGUI
	register_wiget "search multiselect" do
		p = Utils::TestPanel.new
		select = WGUIExt::SearchMultiselect.new ["one", "two", "three", "four", "five"], ["three", "five"]
		p.children << select
		result = Label.new
		p.children << result
		p.children << (Button.new "Check", select do
			result.text = "Check: #{select.selected.inspect}"
		end)
	end
	
	register_wiget "search select" do
		p = Utils::TestPanel.new
		select = WGUIExt::SearchSelect.new ["one", "two", "three", "four", "five"], "three"
		p.children << select
		result = Label.new
		p.children << result
		p.children << (Button.new "Check", select do
			result.text = "Check: #{select.selected}"
		end)
	end
	
	register_wiget "search multiselect modify" do
		p = Utils::TestPanel.new
		select = WGUIExt::SearchMultiselect.new ["one", "two", "three", "four", "five"], ["three", "five", "custom"]
		select.modify = true
		p select.modify
		p.children << select
		result = Label.new
		p.children << result
		p.children << (Button.new "Check", select do
			result.text = "Check: #{select.selected.inspect}"
		end)
	end
	
	register_wiget "search select modify" do
		p = Utils::TestPanel.new
		select = WGUIExt::SearchSelect.new ["one", "two", "three", "four", "five"], "custom"
		select.modify = true		
		p.children << select
		result = Label.new
		p.children << result
		p.children << (Button.new "Check", select do
			result.text = "Check: #{select.selected}"
		end)
	end
	
	register_wiget "collapsible container" do
		cc = WGUIExt::CollapsibleContainer.new :closed
		cc.closed = Label.new("Closed")
		cc.closed_control = Button.new("Open"){cc.mode = :open} 
		cc.open = Label.new("Open")
		cc.open_controls = [Button.new("Close"){cc.mode = :closed}]
		cc
	end
	
	start_webserver; join_webserver;

end