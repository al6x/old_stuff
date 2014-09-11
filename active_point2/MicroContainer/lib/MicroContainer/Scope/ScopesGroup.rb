class ScopesGroup	
	attr_reader :names
	
	def initialize name
		@name = name
		@names = Set.new
	end
	
	def << name
		@names << name
	end
	
	def delete name
		@names.delete name
	end
	
	
	def active?
		@names.all?{|n| Scope.active? n}
	end
	
	def begin
			@names.each{|n| Scope.begin n}
		end
		
		def end
		@names.each{|n| Scope.end n}
	end
end