class TabJS < WComponent
	include Container
	
	attr_accessor :active, :title
	
	children :@panes
	
	def initialize
		super
		@names, @weights, @panes = [], [], []
	end
	
	def add name, wiget, weight = 0
		name.should! :be_a, String
  	wiget.should! :be_a, WGUI::Wiget
		weight.should! :be_a, Numeric
		
		@names << name
		@weights << weight
		@panes << wiget
		refresh	
	end
	
	def active= name
		@active = name
		refresh
	end		
	
	def build
		@names.sort_by_weight! @weights
		@panes.sort_by_weight! @weights
	end
end