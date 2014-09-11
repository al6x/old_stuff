class TabURL < WComponent
	include WPortlet, Container
	
	attr_accessor :active
	
	children :@content, :@controls
	
	def initialize
		super
		@names, @weights, @wigets = [], [], []
	end
	
	def add name, wiget, weight = 0
		name.should! :be_a, String
  	wiget.should! :be_a, WGUI::Wiget
		weight.should! :be_a, Numeric
		
		@names << name
		@weights << weight
		@wigets << wiget
		refresh	
	end
	
	def active= name
		@active = name
		refresh
	end
	
	def state= state
		return if @active == state
		if @names.include? state
			@active = state 
			refresh
		end
	end
	
	def state; @active end
	
	def build
		@content, @controls = nil, []
		
		@names.sort_by_weight! @weights
		
		@names.each_with_index do |name, index|
			if name == active
				@content = @wigets[index]
				@controls << WLabel.new(name)
			else
				@controls << WLink.new(name, name)
			end
		end
	end
	
	def self.state_conversion_strategy; WGUI::Engine::State::StringStateConversionStrategy end
end