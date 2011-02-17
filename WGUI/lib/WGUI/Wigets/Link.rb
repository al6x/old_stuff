class Link < Core::Wiget
	extend Managed
	inject :session => Engine::Session
	
	attr_reader :state, :text
	attr_accessor :evaluated_uri, :portlet
	
	def initialize text = "", state = nil, &alter_state
		@text = text			
		@state = state if state
		@alter_state = alter_state if alter_state
	end
	
	def text= text
		return if @text == text
		refresh
		@text = text
	end
	
	def state= state
		refresh
		@state = state
	end
	
	def alter_state &block
		return unless block		
		@alter_state = block
		refresh
	end
	
	def alter_state= block
		return unless block		
		@alter_state = block
		refresh
	end
	
	def get_alter_state; @alter_state end
end