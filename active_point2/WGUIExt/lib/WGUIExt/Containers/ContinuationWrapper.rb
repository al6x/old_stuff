class ContinuationWrapper < WContinuation	
	attr_accessor :component, :accessor
	
	def original
		if @component
			if @accessor 
				Scope[component].send @accessor
			else
				Scope[component]
			end
		else
			nil
		end 
	end
end