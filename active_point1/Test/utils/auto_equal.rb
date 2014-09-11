module AutoEqual
	def eql? other
		return false unless self.is_a?(other.class) || other.is_a?(self.class)
		return self == other
	end
	
	def == other		
		return false unless instance_variables.sort == other.instance_variables.sort
		instance_variables.each do |name|
			return false unless instance_variable_get(name) == other.instance_variable_get(name)
		end
		return true
	end
	
	def hash
		hash = 0.hash
		instance_variables.each do |name|
			hash ^= instance_variable_get(name).hash
		end
		return hash
	end
end