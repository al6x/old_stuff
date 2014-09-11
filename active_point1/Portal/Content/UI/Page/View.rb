class View < WComponent
	inherit UView
	inherit ActivePoint::Core::UI::Secure::View
	inherit ActivePoint::Core::UI::Layout::View
	inherit ActivePoint::Core::UI::Skinnable::View
	
	build_view do |v|
		form = v.new :box, :style => "float border_left border_top"
		v.root = form
		
		tab = v.new :tab, :active => "Posts", :title => v.object.title, :component_id => "blog_tab"
		form.add tab
		
		tab.add "Posts", build_posts(v)
		tab.add "Details", build_details(v)				
	end				
	
	class << self
		def build_posts v
			pane = v.new :box, :style => "float"
			
			pane.add v.new(:link_button, :text => "Add", :action => :add_post) #if C.user.can? "Edit"
			
			post_view = lambda do |o| 
				Post::Details.new.set :object => o						
			end
			posts = v.new :table, :selector => false, :name => :posts,
			:read_values => [:self], :editors => [post_view], 
			:sort => SORTING_ORDERS[v.object.sorting_order]
			pane.add posts
			
			return pane
		end
		
		def build_details v
			pane = v.new :box, :style => "float"
			
			pane.add v.new(:link_button, :text => "Blog Setting", :action => :edit_setting)				
			
			pane.add v.aspects
			
			return pane
		end
	end
	
	#	def build
	#		super
	#		Scope.add_observer object.om_id, self, :refresh
	#	end
end