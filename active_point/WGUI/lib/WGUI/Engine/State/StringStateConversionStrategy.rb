class StringStateConversionStrategy
	def self.state_to_uri state
		state
	end

	def self.uri_to_state uri
		uri
	end

	def self.empty_state
		""
	end
end