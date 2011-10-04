module WPortlet
	attr_accessor :state	
	
	def update_state; end
	
	# Custom state conversion strategy. 	
	def self.state_conversion_strategy
		# Return some implementation of state conversion strategy.state_conversion_strategy
	end
end