module AttributeMix
	def attribute_near *name_query
		get_attribute :near, name_query
	end
	
	def attribute_left_of *name_query
		get_attribute :left_of, name_query
	end
	
	def attribute_right_of *name_query
		get_attribute :right_of, name_query
	end
	alias :attribute :attribute_right_of
	
	def attribute_top_of *name_query
		get_attribute :top_of, name_query
	end
	
	def attribute_bottom_of *name_query
		get_attribute :bottom_of, name_query
	end
	
	protected
	def get_attribute filter, name_query
		name_query.size.should! :>=, 1
		
		element = if name_query.size > 1
			name_query.size.should! :==, 2
			query, text = name_query
			single(query, text)
		else
			name_query.size.should! :==, 1
			text = name_query[0]
			text.should_not! :be_empty if text.is_a? String
			single(:text, text)
		end
		
		value = list(:any).filter(filter, element)
		raise "Can't find Attribute Value!" if value.size < 1
		raise "Found more than one Attribute Values!" if value.size > 1
		return value
	end
end