class A
	attr_accessor :a
	alias_method :b, :a
end

class B < A
	
end