class View < WComponent
	inherit UView
	
	build_view do |v|
		post = v.new :attributes, :style => "float input font border_left border_top", :title => v.object.title
		v.root = post
		
		# Attributes
		post.add nil, v.new(:richtext_view, :name => :content)		
		post.add "Date", v.new(:date_view, :name => :date)		
		
		# Controls
		controls = v.new :flow, :style => "minimal"
		post.add nil, controls
		
		controls.add v.new(:link_button, :text => "Edit", :action => :edit_post)
		controls.add v.new(:link_button, :text => "Delete", :action => :delete_post)
	end
	
#	def build
#		super
#		Scope.add_observer object.om_id, self, :refresh
#	end
end