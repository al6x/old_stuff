class ShowSitePage < WComponent	
	attr_accessor :object
	
	children :@content, :@edit
	
	def build
		@content = new :richtext_view, :value => object.content		
		@edit = new :link_button, :text => `[Edit]`, :action => :edit_page
	end
end