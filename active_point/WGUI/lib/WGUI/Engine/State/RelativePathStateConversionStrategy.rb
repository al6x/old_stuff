class RelativePathStateConversionStrategy
	extend Log
	def self.state_to_uri state
#		Path.new(state).to_absolute.to_s
		raise "Invalid Path Class '#{state.class.name}' ('#{state}')!" unless state.is_a? Path
		raise "Path isn't relative ('#{state}')!" if state.absolute?
		state.to_s
	end
  		
	def self.uri_to_state uri	
#		Path.new(uri).to_absolute
		path = Path.new(uri)
		"Path '#{path}' isn't relative, will be ignored!" if path.absolute?
		return path			
	end
		
	def self.empty_state
		Path.new('')
	end
end