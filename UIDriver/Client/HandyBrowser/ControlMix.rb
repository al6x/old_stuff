module ControlMix
	def control control_query, filter, object_query
		control_query.should! :be_a, [String, Regexp, Browser::ResultSet]
		control_query.should_not! :be_empty if control_query.is_a? String		
		
		object_query.should! :be_a, [String, Regexp, Browser::ResultSet]
		object_query.should_not! :be_empty if object_query.is_a? String
		
		controls = if control_query.is_a? Browser::ResultSet
			control_query
		else
			list(:control, control_query)
		end
		
		object = if object_query.is_a? Browser::ResultSet
			object_query
		else
			single(:text, object_query)
		end
		
		value = controls.filter(filter, object)
		raise "Can't find Control!" if value.size < 1
		raise "Found more than one Control!" if value.size > 1
		return value
	end
end