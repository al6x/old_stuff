class FindResource
	attr_reader :result
	def initialize component_id
		@component_id, @visit_children = component_id, true
	end
		
	def accept wiget
		if wiget.kind_of?(WResource) && wiget.component_id == @component_id				
			@result = wiget 
			@visit_children = false
		end
	end		
	
	def visit_children?; @visit_children end
end