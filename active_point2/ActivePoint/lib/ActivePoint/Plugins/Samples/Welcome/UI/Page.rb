class Page
	attr_reader :view
	
	def initialize
		@view = DefaultView.new
		@view.object = C.object
	end
end