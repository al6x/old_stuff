class Flow < WComponent
	include Container
	
	attr_accessor :children, :title
	
	children :children
	
	def initialize
		super
		@children, @weights = [], []
	end    	
	
	def add child, weight = 0
		child.should! :be_a, WGUI::Wiget
		weight.should! :be_a, Numeric
		
		children << child
		@weights << weight
		refresh
	end
	
	def build		
		children.sort_by_weight! @weights
	end	
end