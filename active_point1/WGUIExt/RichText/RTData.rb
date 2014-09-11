class RTData
	attr_accessor :text, :resources
	
	def initialize text = "", resources = []
		@text, @resources = text, resources
	end
	
	def clone
		RTData.new @text.clone, @resources.clone
	end
end