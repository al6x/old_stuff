module Editor
	attr_accessor :name, :before_read, :before_write, :style
	
	def name= value
		@name = value
		self.component_id = "#{value}_#{component_id}"
	end
	
	def read object
		raise "Object is nil!" unless object
		value = if object.is_a? Hash
			object[name]
		else
			object.send name
		end
		value = before_read.call value if before_read		
		self.value = value
	end
	
	def write object
		raise "Object is nil!" unless object
		value = if before_write			
			before_write.call self.value
		else
			self.value
		end
		if object.is_a? Hash
			object[name] = value
		else
			object.send name.to_writer, value
		end			
	end		
end