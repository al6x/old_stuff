class Border < WComponent
	include Container
	
	#	attr_accessor :positions
	
	attr_accessor :center, :left, :right, :top, :bottom, :wide
	children :center, :left, :right, :top, :bottom
	
	def initialize
		super
		@wide = true
		self.css = "container font input"
	end
	
	def add position, wiget		
		position.should! :be_in, [:center, :left, :right, :top, :bottom]
		wiget.should! :be_a, [Array, WGUI::Wiget]
		
		send position.to_writer, wiget
	end	
	
	def dsl_center container, parameters = nil, &b
		dsl_add :center, container, parameters, &b
	end
	
	def dsl_left container, parameters = nil, &b
		dsl_add :left, container, parameters, &b
	end
	
	def dsl_top container, parameters = nil, &b
		dsl_add :top, container, parameters, &b
	end
	
	def dsl_right container, parameters = nil, &b
		dsl_add :right, container, parameters, &b
	end
	
	def dsl_bottom container, parameters = nil, &b
		dsl_add :bottom, container, parameters, &b
	end
	
	def dsl_add position, container, parameters, &b
		if container.is_a? Symbol
			add position, dsl_builder.new(container, parameters, &b)
		elsif container.is_a? Core::Wiget
			add position, container
		else
			should! :be_never_called
		end
	end
end