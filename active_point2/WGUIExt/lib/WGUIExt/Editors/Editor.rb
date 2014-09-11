module Editor
	attr_accessor :attr, :before_read, :before_write
	
	def attr= value
		@attr = value
		self.component_id = "#{value}_#{component_id}"
	end
	
	def read object
		raise "Object is nil!" unless object
		value = if object.is_a? Hash
			object[attr]
		else
			object.send attr
		end
		value = before_read.call value if before_read		
		self.value = value
	end
	
	def write object
		raise "Object is nil!" unless object
		return unless self.respond_to? :value
		
		value = if before_write			
			before_write.call self.value
		else
			self.value
		end

		if object.is_a? Hash
			object[attr] = value
		else
			object.send attr.to_writer, value
		end			
	end		
end