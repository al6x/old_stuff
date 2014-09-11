class Edit < WComponent
	inherit UView
	
	attr_accessor :on_ok, :on_cancel
	
	build_view do |v|				
		form = v.new :box, :style => "float border_left border_top"
		v.root = form
		
		tab = v.new :tab_js, :active => "General", :title => "Edit Post"
		form.add tab
		
		general = v.new :attributes
		tab.add "General", general
			
		general.add "Title", v.new(:string_edit, :name => :title)								
		general.add "Details", v.new(:text_edit, :name => :details)		
		general.add nil, v.new(:richtext_edit, :name => :content)			
		general.add "Date", v.new(:date_edit, :name => :date)		
		
		extra = v.new :attributes
		tab.add "Extra", extra
		
		extra.add "URI", v.new(:string_edit, :name => :entity_id)				
		extra.add "Icon", v.new(:image_edit, :name => :icon, :style => "icon")
		
		controls = v.new :flow, :style => "minimal"
		form.add controls
		controls.add v.new(:button, :text => "Ok", :action => [form, v.on_ok])
		controls.add v.new(:button, :text => "Cancel", :action => v.on_cancel)						
	end
end