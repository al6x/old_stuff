class WResource < Core::Wiget
	extend Injectable
	
	attr_reader :data
	attr_accessor  :open_in_the_same_window												
		
	
	def initialize data = nil
		super()
		self.data = data
	end
	
	# TODO Add the 'WResource to URI' method to the ConversionStrategy.
	
	def data= data
		refresh
		if data
			begin
			self.component_id = data.resource_id
			@data = data
		rescue Exception => e
			where?
			raise e
			end
		end
	end
end