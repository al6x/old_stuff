class TabJS < WComponent
	include Container
	
	attr_accessor :active, :title, :wide
	
	children :@panes
	
	def initialize
		super
		@names, @weights, @panes = [], [], []
		@wide = true
		self.css = "container font input"
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
	
	def dsl_add name, container, parameters = nil, &b
  	name.should! :be_a, String  
  	if container.is_a? Symbol
  		add name, dsl_builder.new(container, parameters, &b)
  	elsif container.is_a? Core::Wiget
  		add name, container
  	else
  		should! :be_never_called
  	end
  end
  
  def dsl_add_wiget wiget, name
  	add name, wiget
  end
	
	def build
		@names.sort_by_weight! @weights
		@panes.sort_by_weight! @weights
	end
end