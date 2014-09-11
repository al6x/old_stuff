class String
	def to_reader
		self.to_sym
	end
	
	def to_writer
		"#{self}=".to_sym
	end
	
	def to_iv
		"@#{self}"
	end
	
	def substitute binding
		binding.should! :be_a, Binding
		return gsub(/\#\{.+?\}/) do |term|
			identifier = term.slice(2 .. term.size-2)
			binding.eval identifier
		end
	end
end