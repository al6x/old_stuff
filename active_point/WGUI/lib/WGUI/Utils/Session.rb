class Session
	class << self
		def generate_id
			bits = $debug ? 8 : CONFIG[:sid_bits]
			"%0#{bits / 4}x" % rand(2**bits - 1)
		end
	end
end