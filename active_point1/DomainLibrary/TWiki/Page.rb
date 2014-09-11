class Page
	include OGDomain:: Entity
	
	build_dmeta do |m|		
		m.entity_name "Page"		
		
		# Attributes
		m.attribute :text, :object, "Text", :initialize => WGUIExt::RichText::RTData.new
		m.attribute :children, :entity, "Children", :container => :array
		m.children :children
		
		# Actions						
		m.action :on_view, Actions::View		
		m.action :edit, Actions::Edit		
		m.action :add, Actions::Add		
		m.action :delete, Actions::Delete
	end
end