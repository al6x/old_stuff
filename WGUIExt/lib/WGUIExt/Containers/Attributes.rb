class Attributes < WComponent
	include Container
	
	attr_accessor :title, :metadata, :title_css, :wide
	attr_reader :editors, :labels
	
	children :editors
	
	def initialize
		super
		@labels = []
		@editors = []
		@weights = []
		@wide = true
		self.css = "container font input"
	end  
	
	def add label, editors, weight = 0
		label.should! :be_a, [NilClass, String]
		editors.should! :be_a, [Array, WGUI::Wiget]
		weight.should! :be_a, Numeric
		
		if label.is_a? Symbol 
			label = Attributes.label_resolver.call metadata, label if Attributes.label_resolver
		end
		labels << label
		self.editors << (editors.is_a?(Array) ? editors : [editors])		
		@weights << weight   
		refresh
	end
	
	def dsl_add label, *parameters
		if parameters.size > 0
			if parameters[0].is_a? Array
				editors = parameters[0].should! :be_a, Array
				add label, editors
			else
				params = parameters.size > 1 ? parameters[1].should!(:be_a, Hash) : nil
				editor = if parameters[0].is_a? Core::Wiget
					parameters[0]
				else
					walias = parameters[0].should!(:be_a, Symbol)				
					dsl_builder.new walias, params
				end
				add label, editor
			end						
		else
			should! :be_never_called
		end
	end
	
	def build		
		labels.sort_by_weight! @weights
		editors.sort_by_weight! @weights
	end		
	
	class << self
		attr_accessor :label_resolver
	end
end