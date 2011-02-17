class DefaultStateConversionStrategy    
	extend Log
	def self.state_to_uri state
		uri = Path.new('')
		state.sort.each do |pair|
			uri = uri.add(pair[0])
			uri = uri.add(pair[1])
		end
		uri.to_s
	end
	
	def self.uri_to_state uri		
		key, state = nil, {}
		uri = Path.new(uri)
		raise "Url '#{uri}' has invalid format, will be ignored" if uri.absolute?
		uri.each do |part|
			if key
				state[key] = part.to_s
				key = nil
			else
				key = part.to_s
			end
		end
		if uri.size % 2 != 0
			raise "Bad URI '#{uri}' (will not be fully processed)!"
			#            raise "Invalid State!"
		end		
		return state
	end
	
	def self.empty_state; {}end
	end  