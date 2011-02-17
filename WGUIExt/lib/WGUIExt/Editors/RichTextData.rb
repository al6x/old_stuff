class RichTextData
	attr_accessor :text, :resources
	
	def initialize text = "", resources = []
		@text, @resources = text, resources
	end
	
	def clone
		RichTextData.new @text.clone, @resources.clone
	end
end