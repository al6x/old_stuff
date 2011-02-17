class Line < WComponent
	include Container
	
	attr_accessor :children, :title, :wide
	
	children :children
	
	def initialize
		super
		@children, @weights = [], []
		@wide = true
		self.css = "container font input"
	end    	
	
	def add child, weight = 0
		child.should! :be_a, WGUI::Wiget
		weight.should! :be_a, Numeric
		
		children << child
		@weights << weight
		refresh
	end
	alias :dsl_add_wiget :add	
	
	def build		
		children.sort_by_weight! @weights
	end	
end