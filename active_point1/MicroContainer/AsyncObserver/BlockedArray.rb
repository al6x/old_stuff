class BlockedArray
	include MonitorMixin
		
	def initialize
		super
		@condition = new_cond
		@array = []
	end
		
	def signal; synchronize{@condition.signal} end
		
	def add value; synchronize{@array << value} end
		
	# Blocks untill there will be some messages
	def get_array
		synchronize do
			@condition.wait_until{@array.size > 0}
			a = @array
			@array = []
			return a
		end
	end
end