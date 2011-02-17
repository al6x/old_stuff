class Select < WComponent
	include Editor	
	
	SIMPLE_EDITOR_LIMIT = 20
	
	children :@content    
	
	def build
		unless multiple			
			if values.size < simple_editor_limit
				@content = WSelect.new(@values, @value).set(:modify => @modify, :css => "input")
			else
				@content = build_complex_select(@values, @value)
			end
		else
			@value ||= []
			if values.size < simple_editor_limit									
				@content = WMultiselect.new(@values, @value).set(:modify => @modify, :css => "input")
			else				
				@content = build_complex_multiselect(@values, @value)
			end
		end
	end
	
	def build_complex_select values, selected
		cc = WGUIExt::Containers::CollapsibleContainer.new		
		cc.closed = WLabel.new(selected)
		cc.closed_control = WButton.new(to_l("Edit")){cc.mode = :open}
		cc.open = WGUIExt::Editors::SearchSelect.new(values, selected).set(:modify => @modify)
		cc.open_controls = WButton.new(to_l("Ok")) do
			cc.closed.text = cc.open.selected
			cc.mode = :closed
		end
		cc
	end
	
	def build_complex_multiselect values, selected
		cc = WGUIExt::Containers::CollapsibleContainer.new		
		cc.closed = ListView.new
		cc.closed.value = selected		
#		cc.closed = WigetBag.new(selected.collect{|item| WLabel.new(item)})
		cc.closed_control = WButton.new(to_l("Edit")){cc.mode = :open}
		cc.open = WGUIExt::Editors::SearchMultiselect.new(values, selected).set(:modify => @modify)
		cc.open_controls = WButton.new(to_l("Ok")) do
			list = ListView.new
			list.value = cc.open.selected
			cc.closed = list
			cc.mode = :closed
		end
		cc		
	end
	
	def value
		selected = nil
		if values.size < simple_editor_limit
			selected = @content.selected
		else
			selected = @content.open.selected
		end
		
		unless multiple
			if values
				@value = selected
			else
				return nil
			end
		else
			if values
				@value = selected
			else
				return []
			end
		end
	end
	
	def values
		@values ||= []
	end
	
	def values= values
		values.should! :be_a, Enumerable
		@values = values
		refresh
	end
	
	def multiple
		@multiple ||= false
	end
	
	def multiple= multiple
		multiple.should! :be_in, [true, false]
		@multiple = multiple
		refresh
	end
	
	def modify= modify
		modify.should! :be_in, [true, false]
		@modify = modify
		refresh
	end
	
#	def labels= labels
#		labels.should! :be_a, Array
#		@labels = labels
#		refresh
#	end
	
	def value= value
		@value = value
		refresh
	end
	
	def simple_editor_limit
		@simple_editor_limit ||= SIMPLE_EDITOR_LIMIT
	end
	
	def simple_editor_limit= count
		@simple_editor_limit = count
		refresh
	end
	
	protected
#	def to_value label
#		index = @labels.index(label).should_not!(:be_nil).should!(:>=, 0)
#		@values[index]
##		@string_values.each_with_index do |v, i|
##			return values[i] if v == string_value
##		end
##		return nil
#	end
#	
#	def to_label value
#		index = @values.index(value).should_not!(:be_nil).should!(:>=, 0)
#		@labels[index]
##		return "" unless o
##		@labels ? @labels.call(o) : o.to_s
#	end
end