module ::Utils
	class SerializableLambda
		class << self
			def get_source proc
				@registry ||= {}
				source = @registry[proc.object_id]
				raise "There is no source code for '#{proc}'!" unless source
				return source
			end
		
			def set_source proc, source
				@registry ||= {}
				@registry[proc.object_id] = source
			end
		end
	end	
end

class Object
	def lambdas code
		proc = eval "lambda #{code}"
		::Utils::SerializableLambda.set_source proc, code
		return proc
	end
end