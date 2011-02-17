class Messages < WComponent	
	extend Managed
	scope :object
	
	def initialize		
		super
		@messages = []
		self.visible = true
	end
	
	def error message		
		@messages << [message, :error]
		self.visible = true
	end
	
	def info message
		@messages << [message, :info]
		self.visible = true
	end
	
	def warn message
		@messages << [message, :warn]
		self.visible = true
	end
	
	def clear
		@messages = []
		self.visible = false
	end
end