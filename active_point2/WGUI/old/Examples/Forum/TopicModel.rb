class TopicModel
	include OpenConstructor
	attr_accessor :name, :text, :comments
	def initialize
		@name, @text, @comments = '', '', []
	end
end		