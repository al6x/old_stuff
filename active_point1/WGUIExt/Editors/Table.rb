class Table < WComponent
	include Editor
	
	attr_accessor :head, :read_values, :editors, :selector, :sort
	
	children :@wrows, :@wcheckboxes  
	
	def initialize
		super
		@selector = true
	end
	
#	def selected_indexes
#		return [] unless selector
#		selected = []
#    @wcheckboxes.each_with_index{|cb, i| selected << i if cb.selected}
#    return selected
#	end
	
	def selected
		return [] unless selector or (@value and !@value.empty?)
		selected = []
    @wcheckboxes.each_with_index{|cb, i| selected << @objects[i] if cb.selected}
    return selected
	end
	
	def sort= proc
		proc.should! :be_a, [NilClass, Proc]
		@sort = proc
		refresh
	end
	
	def build      
		if @value and !@value.empty?
			@wcheckboxes, @objects = [], [] if selector
			@wrows = []
			each = lambda do |o|
				@wcheckboxes << WCheckbox.new(false) if selector
				@objects << o if selector
				row = []
				read_values.each_with_index do |accessor, index|
					cell_editor = editors[index]
					cell_value = if accessor.is_a? Symbol
						o.send(accessor)
					elsif accessor.is_a? Proc
						accessor.call o, index
					else
						should! :be_never_called
					end
					cell = cell_editor.call cell_value
					row << cell
				end
				@wrows << row
			end
			if @sort
				@value.sort(&@sort).each &each
			else
				@value.each &each
			end
		else
			@wcheckboxes = [] if selector
			@wrows = []
		end				
	end
	
	def value= data		
		@value = data
		refresh
	end
	attr_reader :value
	
	def collect_values
		if @value
			matrix = []
			@wrows.each do |row|
				line = []
				matrix << line
				row.each do |editor|
					line << editor.respond_to(:value)
				end
			end
			matrix
		else 
			[]
		end
	end
	
	def head= head
		@head = head
		refresh
	end
	
#	def values= values
#		@values = values
#		refresh
#	end		
end