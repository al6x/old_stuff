module ::Utils
	module OpenConstructor
		def set hash
			hash.each do |k, v|
				m = :"#{k}="
				self.send m, v if self.respond_to? m
			end
			return self
		end
	
		def self.copy from, to
			from.each do |k, v|
				to.send("#{k}=", v)
			end
		end        
	end
end	
