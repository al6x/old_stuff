class SearchMultiselect < WComponent
	children :@search_field, :@search_button, :@found, :@add, :@selected_list, :@delete, :@add_field, :@add_button
	
	attr_reader :selected, :values, :multiple, :modify
	
	def initialize values = [], selected = []
		super()
		@values = values
		
		@search_field = TextField.new	""
		@search_button = Button.new(to_l("Search"), @search_field) do
			@term = @search_field.text.downcase
			rebuild_found
		end
		
		@found = Multiselect.new
		
		@add = Button.new(to_l("Select"), @found){add_values}
		
		@selected_list = Multiselect.new selected, []
		
		@delete = Button.new(to_l("Unselect"), @selected_list){delete_values}				
	end
	
	def build
		if modify
			@add_field = TextField.new
			@add_button = Button.new to_l("Add"), @add_field do
				@selected_list.values << @add_field.text		
				refresh
			end
		end
	end
	
	def selected= value
		@selected_list.values = value
		@selected_list.selected = []
		
		rebuild_found
	end
	
	def selected
		@selected_list.values
	end
	
	def values= values
		@values = values
		
		rebuild_found
	end
	
	def multiple= multiple		
		@multiple = multiple
		
		rebuild_found
	end
	
	def modify= value
		return if @modify == value
		@modify = value
		refresh
	end
	
	protected
	def rebuild_found
		return unless @term									
		search_result = @values.select{|item| item.downcase.index(@term)}			
		@selected_list.values.each{|item| search_result.delete item} unless multiple
		
		@found.values, @found.selected = search_result, []	
		
		refresh
	end
	
	def delete_values
		@selected_list.values = @selected_list.values - @selected_list.selected
		@selected_list.selected = []
		
		rebuild_found
		refresh
	end	
	
	def add_values
		@found.selected.each{|item| @selected_list.values << item}
		
		rebuild_found
		refresh
	end
end