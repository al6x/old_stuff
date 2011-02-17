class SearchSelect < WComponent
	children :@search_field, :@search_button, :@found, :@select_button, :@selected_label, :@add_field, :@add_button
	
	attr_reader :selected, :values, :modify
	
	def initialize values = [], selected = nil
		super()
		@values, @selected = values, selected
		@search_string = nil
		@modify = false
	end
	
	def build
		search_result = []
		if @search_string
			search_result = values.select{|item| item.downcase.index(@search_string)} 			
			search_result.delete @selected
		end		
		
		@search_field = TextField.new	@search_string || ""	
		@search_button = Button.new to_l("Search"), @search_field do
			@search_string = @search_field.text.downcase							
			refresh
		end
		
		@found = Multiselect.new search_result		
		
		@select_button = Button.new to_l("Select"), @found do
			if @found.selected.size > 0
				@selected = @found.selected[0]
				refresh
			end			
		end
		
		@selected_label = TextField.new(@selected || "").set :disabled => true
		
		if modify
			@add_field = TextField.new
			@add_button = Button.new to_l("Add"), @add_field do
				@selected = @add_field.text
				refresh
			end
		end
	end
	
	def selected= value
		return if @selected == value
		@selected = value
		refresh
	end
	
	def values= values
		return if @values == values
		@values = values
		refresh
	end
	
	def modify= value
		return if @modify == value
		@modify = value
		refresh
	end
end