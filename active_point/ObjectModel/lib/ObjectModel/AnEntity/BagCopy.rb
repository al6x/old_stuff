class BagCopy
	def initialize array
		@array = array
	end
	
	def _array
		@array
	end
		
	def delete_if &b
		@array.delete_if &b
	end
	
	def size
		@array.size
	end
	
	def add value
		@array << value
	end
	
	def clear
		@array.clear
	end
	
	def each &b
		@array.each &b
	end		
end