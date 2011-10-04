class LocaleType < Types::ObjectType
	class << self
		def initial_value m, e
			e.instance_variable_set m.ivname, {}
		end
		
		def validate_type value
			value.is_a? Hash
		end
	end
end