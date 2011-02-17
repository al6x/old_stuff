class CollapsibleContainer < WComponent
	children :open, :closed, :open_controls, :closed_control	
	
	attr_accessor :open, :closed, :open_controls, :closed_control, :mode
	
	# mode = :open, :closed
	def initialize mode = :closed
		super()		
		@mode = mode
	end
	
	def mode= mode
		return if @mode == mode
		@mode = mode
		refresh
	end		
end
