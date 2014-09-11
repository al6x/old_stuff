class ShowHTMLPage < WComponent
	attr_accessor :object
	
	def build
		@edit = new :link_button, :text => `[Edit]`, :action => :edit
	end
end