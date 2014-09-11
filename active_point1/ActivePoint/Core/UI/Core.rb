class Core
	inherit Controller
	
	def initialize
		build_view
	end
	
	protected
	def build_view
		@view = View.new
		@view.object = C.object
	end
end