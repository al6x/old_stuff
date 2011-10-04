class Table < WComponent
	include Container, Editors::Editor
	
	attr_accessor :selector, :sort, :wide
	attr_reader :range
	
	children :@whead, :@wrows, :@wcheckboxes  
	
	def initialize
		super
		@selector, @wide, @range = false, true, 1..20
		self.css = "container font input"
	end
	
	#	def selected_indexes
	#		return [] unless selector
	#		selected = []
	#    @wcheckboxes.each_with_index{|cb, i| selected << i if cb.selected}
	#    return selected
	#	end
	
	def selected
		return [] unless @selector or (@value and !@value.empty?)
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
		@whead, @wrows = ArrayContainer.new, []
		@wcheckboxes, @objects = [], []
		
		if @head_dsl
			builder = Form::DSLBuilder.new &@head_dsl
			builder.build @whead, @value
		end
		
		if @value 
			@body_dsl.should_not! :be_nil
			each = lambda do |row|
				if @selector
					@wcheckboxes << WCheckbox.new(false) 
					@objects << row
				end
				
				visual_row = ArrayContainer.new
				builder = Form::DSLBuilder.new &@body_dsl
				builder.build visual_row, row
				
				@wrows << visual_row
			end
			
			if @sort
				@value.sort(&@sort).each &each
			else
				@value.each &each
			end
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
	
	def range= range
		@range = range
		refresh
	end
	
#	def head= head
#		@head = head
#		refresh
#	end
	
	def dsl_head &b
		b.should_not! :be_nil
		@head_dsl = b
	end
	
	def dsl_body &b
		@body_dsl = b
	end		
	
	class ArrayContainer < Array
		include Container
		
		def dsl_add_wiget wiget
			self << wiget
		end
	end
	
	#	def values= values
	#		@values = values
	#		refresh
	#	end		
end